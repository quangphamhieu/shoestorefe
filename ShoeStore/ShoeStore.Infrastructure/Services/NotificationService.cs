using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Notification;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Application.Services
{
    public class NotificationService : INotificationService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public NotificationService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        // ✅ GET ALL
        public async Task<IEnumerable<NotificationDto>> GetAllAsync()
        {
            var notifications = await _context.Notifications
                .OrderByDescending(n => n.CreatedAt)
                .ToListAsync();

            return notifications.Select(n => _mapper.Map<NotificationDto>(n));
        }

        // ✅ GET BY ID
        public async Task<NotificationDto?> GetByIdAsync(long id)
        {
            var n = await _context.Notifications.FindAsync(id);
            if (n == null) return null;

            return _mapper.Map<NotificationDto>(n);
        }

        // ✅ CREATE
        public async Task<NotificationDto> CreateAsync(CreateNotificationDto dto)
        {
            // uniqueness check (title)
            if (!string.IsNullOrWhiteSpace(dto.Title))
            {
                var exists = await _context.Notifications.AnyAsync(n => n.Title == dto.Title);
                if (exists)
                    throw new InvalidOperationException("Notification title already exists.");
            }

            var now = DateTime.UtcNow;
            var code = $"NTF-{now:yyyyMMddHHmmss}";

            var entity = new Notification
            {
                Code = code,
                Title = dto.Title,
                Message = dto.Message,
                Type = dto.Type,
                CreatedAt = now
            };

            // Check if there's already a transaction in progress
            var currentTransaction = _context.Database.CurrentTransaction;
            if (currentTransaction == null)
            {
                // No transaction exists, create a new one
                await using var txn = await _context.Database.BeginTransactionAsync();
                _context.Notifications.Add(entity);
                await _context.SaveChangesAsync();
                await txn.CommitAsync();
            }
            else
            {
                // Transaction already exists, just save changes (will be part of the existing transaction)
                _context.Notifications.Add(entity);
                await _context.SaveChangesAsync();
            }

            return _mapper.Map<NotificationDto>(entity);
        }

        // ✅ DELETE
        public async Task<bool> DeleteAsync(long id)
        {
            var notification = await _context.Notifications.FindAsync(id);
            if (notification == null) return false;

            _context.Notifications.Remove(notification);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
