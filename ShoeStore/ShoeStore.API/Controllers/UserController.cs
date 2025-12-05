using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.DTOs.Users;
using ShoeStore.Application.Interfaces;

namespace ShoeStore.WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IUserService _userService;

        public UserController(IUserService userService)
        {
            _userService = userService;
        }

        // -------------------- GET ALL --------------------
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var users = await _userService.GetAllAsync();
            return Ok(users);
        }

        // -------------------- GET BY ID --------------------
        [HttpGet("{id:long}")]
        public async Task<IActionResult> GetById(long id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
                return NotFound("Không tìm thấy người dùng.");
            return Ok(user);
        }

        // -------------------- CREATE --------------------
        [HttpPost]
        [Authorize(Policy = "USER_CREATE")]
        public async Task<IActionResult> Create([FromBody] UserCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
        }

        // -------------------- UPDATE --------------------
        [HttpPut("{id:long}")]
        [Authorize(Policy = "USER_UPDATE")]
        public async Task<IActionResult> Update(long id, [FromBody] UserUpdateDto dto)
        {
            if (id != dto.Id)
                return BadRequest("Id không khớp.");

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userService.UpdateAsync(dto);
            return Ok(result);
        }

        // -------------------- DELETE --------------------
        [HttpDelete("{id:long}")]
        [Authorize(Policy = "USER_DELETE")]
        public async Task<IActionResult> Delete(long id)
        {
            var result = await _userService.DeleteAsync(id);
            if (!result)
                return NotFound("Không tìm thấy người dùng.");
            return Ok("Đã xóa người dùng thành công.");
        }

        // -------------------- SIGNUP --------------------
        [HttpPost("signup")]
        public async Task<IActionResult> Signup([FromBody] UserSignUpDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userService.SignupAsync(dto);
            return Ok(result);
        }

        // -------------------- LOGIN --------------------
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginDto dto)
        {
            var result = await _userService.LoginAsync(dto);
            if (result == null)
                return Unauthorized("Sai tài khoản hoặc mật khẩu.");
            return Ok(result);
        }

        // -------------------- RESET PASSWORD --------------------
        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword([FromBody] UserResetPassDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userService.ResetPasswordAsync(dto);
            if (!result)
                return BadRequest("Đổi mật khẩu thất bại.");
            return Ok("Đổi mật khẩu thành công.");
        }

        // -------------------- UPDATE MY PROFILE --------------------
        [HttpPut("my-profile")]
        [Authorize] // Any authenticated user can update their own profile
        public async Task<IActionResult> UpdateMyProfile([FromBody] UserUpdateDto dto)
        {
            // Get userId from JWT token
            var userIdClaim = User.FindFirst("userId") 
                ?? User.FindFirst("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier");
            
            if (userIdClaim == null || !long.TryParse(userIdClaim.Value, out long userId))
                return Unauthorized("Invalid token.");

            // Ensure user can only update their own profile
            if (userId != dto.Id)
                return Forbid("You can only update your own profile.");

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _userService.UpdateAsync(dto);
            return Ok(result);
        }
    }
}