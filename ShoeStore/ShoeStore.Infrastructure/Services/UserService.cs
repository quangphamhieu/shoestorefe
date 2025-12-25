using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.DTOs.Users;
using ShoeStore.Application.Interfaces;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Mail;
using ShoeStore.Infrastructure.Persistence;
using ShoeStore.Infrastructure.Security;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ShoeStore.Application.Services
{
    public class UserService : IUserService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly JwtTokenGenerator _jwtTokenGenerator;
        private readonly PasswordHelper _passwordHelper;
        private readonly IEmailService _emailService;
        private readonly IMapper _mapper;

        public UserService(ShoeStoreDbContext context, JwtTokenGenerator jwtTokenGenerator, PasswordHelper passwordHelper, IEmailService emailService, IMapper mapper)
        {
            _context = context;
            _jwtTokenGenerator = jwtTokenGenerator;
            _passwordHelper = passwordHelper;
            _emailService = emailService;
            _mapper = mapper;
        }

        public async Task<UserDto> CreateAsync(UserCreateDto dto)
        {
            // uniqueness check on phone/email
            if (await _context.Users.AnyAsync(u => u.Phone == dto.Phone || (!string.IsNullOrWhiteSpace(dto.Email) && u.Email == dto.Email)))
                throw new InvalidOperationException("Phone or email already exists.");

            var user = _mapper.Map<User>(dto);
            user.PasswordHash = _passwordHelper.HashPassword(dto.Password);
            user.StatusId = 1;
            user.CreatedAt = DateTime.UtcNow;

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var roleName = await _context.Roles
                .Where(r => r.Id == user.RoleId)
                .Select(r => r.Name)
                .FirstOrDefaultAsync();

            var statusName = await _context.Statuses
                .Where(s => s.Id == user.StatusId)
                .Select(s => s.Name)
                .FirstOrDefaultAsync();

            var result = _mapper.Map<UserDto>(user);
            result.RoleName = roleName ?? string.Empty;
            result.StatusName = statusName ?? string.Empty;
            return result;
        }

        public async Task<bool> DeleteAsync(long id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
                return false;

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<IEnumerable<UserDto>> GetAllAsync()
        {
            var users = await _context.Users
                .Include(u => u.Role)
                .Include(u => u.Status)
                .ToListAsync();

            return users.Select(u => _mapper.Map<UserDto>(u));
        }

        public async Task<UserDto?> GetByIdAsync(long id)
        {
            var u = await _context.Users
                .Include(u => u.Role)
                .Include(u => u.Status)
                .FirstOrDefaultAsync(u => u.Id == id);

            if (u == null) return null;

            return _mapper.Map<UserDto>(u);
        }

        public async Task<UserLoginResponseDto?> LoginAsync(UserLoginDto dto)
        {
            var user = await _context.Users
            .Include(u => u.Role)
            .FirstOrDefaultAsync(u => u.Phone == dto.PhoneOrEmail || u.Email == dto.PhoneOrEmail);

            if (user == null)
                return null;
            var permissions = await _context.RolePermissions
                .Where(rp => rp.RoleId == user.RoleId)
                .Select(rp => rp.Permission.Code)
                .ToListAsync();
            if (!_passwordHelper.VerifyPassword(dto.Password, user.PasswordHash))
                return null;
            var token = _jwtTokenGenerator.GenerateToken(user.Id, user.FullName, user.Role.Name,permissions);

            return new UserLoginResponseDto
            {
                UserId = user.Id,
                FullName = user.FullName,
                RoleName = user.Role.Name,
                Token = token
            };
        }

        public async Task<bool> ChangePasswordAsync(UserChangePasswordDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Phone == dto.PhoneOrEmail || u.Email == dto.PhoneOrEmail);
            if (user == null)
                throw new InvalidOperationException("User not found.");

            if (!_passwordHelper.VerifyPassword(dto.OldPassword, user.PasswordHash))
                throw new InvalidOperationException("Old password is incorrect.");

            user.PasswordHash = _passwordHelper.HashPassword(dto.NewPassword);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> ForgotPasswordAsync(UserForgotPasswordDto dto)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.Phone == dto.PhoneOrEmail || u.Email == dto.PhoneOrEmail);
            if (user == null)
                throw new InvalidOperationException("Không tìm thấy người dùng.");

            // Kiểm tra email có hợp lệ không
            if (string.IsNullOrWhiteSpace(user.Email))
                throw new InvalidOperationException("Người dùng không có email để nhận mật khẩu mới.");

            // Tạo mật khẩu ngẫu nhiên
            string newPassword = GenerateRandomPassword();

            // Hash và lưu mật khẩu mới
            user.PasswordHash = _passwordHelper.HashPassword(newPassword);
            await _context.SaveChangesAsync();

            // Gửi email với mật khẩu mới
            string subject = "Khôi phục mật khẩu - HieuShoeStore";
            string html = $"<p>Xin chào {user.FullName},</p>" +
                          $"<p>Mật khẩu mới của bạn là: <strong>{newPassword}</strong></p>" +
                          $"<p>Vui lòng đăng nhập và đổi mật khẩu ngay sau khi nhận được email này.</p>" +
                          $"<p>Nếu bạn không yêu cầu khôi phục mật khẩu, vui lòng liên hệ với chúng tôi ngay.</p>";
            
            await _emailService.SendEmailAsync(user.Email, subject, html);

            return true;
        }

        private string GenerateRandomPassword()
        {
            const string upperChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            const string lowerChars = "abcdefghijklmnopqrstuvwxyz";
            const string digitChars = "0123456789";
            const string specialChars = "!@#$%^&*";
            const string allChars = upperChars + lowerChars + digitChars + specialChars;

            var random = new Random();
            var password = new char[10];

            // Đảm bảo có ít nhất 1 ký tự mỗi loại
            password[0] = upperChars[random.Next(upperChars.Length)];
            password[1] = lowerChars[random.Next(lowerChars.Length)];
            password[2] = digitChars[random.Next(digitChars.Length)];
            password[3] = specialChars[random.Next(specialChars.Length)];

            // Điền các ký tự còn lại ngẫu nhiên
            for (int i = 4; i < password.Length; i++)
            {
                password[i] = allChars[random.Next(allChars.Length)];
            }

            // Xáo trộn mật khẩu
            return new string(password.OrderBy(x => random.Next()).ToArray());
        }

        public async Task<UserDto> SignupAsync(UserSignUpDto dto)
        {
            // trim input ngay từ đầu
            var phone = dto.Phone?.Trim();
            var email = dto.Email?.Trim();

            if (await _context.Users.AnyAsync(u => u.Phone == phone || u.Email == email))
                throw new InvalidOperationException("Số điện thoại hoặc email đã tồn tại.");

            var user = new User
            {
                FullName = dto.FullName?.Trim(),
                Phone = phone,
                Email = email,
                Gender = dto.Gender,
                PasswordHash = _passwordHelper.HashPassword(dto.Password),
                RoleId = 4,
                StatusId = 1,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            // Gửi email nếu hợp lệ
            if (!string.IsNullOrWhiteSpace(user.Email))
            {
                string subject = "Welcome to HieuShoeStore";
                string html = $"<p>Xin chào {user.FullName},</p>" +
                              $"<p>Tài khoản của bạn đã được tạo thành công!</p>" +
                              $"<p>Email: {user.Email}</p>" +
                              $"<p>Password: {dto.Password}</p>";
                await _emailService.SendEmailAsync(user.Email, subject, html);
            }


            return _mapper.Map<UserDto>(user);
        }

        public async Task<UserDto?> UpdateAsync(UserUpdateDto dto)
        {
            var user = await _context.Users
                .Include(u => u.Role)
                .Include(u => u.Status)
                .FirstOrDefaultAsync(u => u.Id == dto.Id);
            if (user == null)
                return null;

            user.FullName = dto.FullName;
            user.Phone = dto.Phone;
            user.Email = dto.Email;
            user.Gender = dto.Gender;
            user.RoleId = dto.RoleId;
            user.StatusId = dto.StatusId;
            user.StoreId = dto.StoreId;

            await _context.SaveChangesAsync();

            return _mapper.Map<UserDto>(user);
        }
    }
}