using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.DTOs.Users
{
    public class UserResetPassDto
    {
        [Required]
        public string PhoneOrEmail { get; set; } = null!;

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; } = null!;

        // OldPassword optional when doing reset via OTP/forgot flow
        public string? OldPassword { get; set; } // dùng khi người dùng tự đổi

        // OTP code optional: if provided, indicates forgot password flow
        public string? OtpCode { get; set; }
    }
}