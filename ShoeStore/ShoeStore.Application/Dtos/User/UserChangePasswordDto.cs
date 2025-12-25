using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.DTOs.Users
{
    public class UserChangePasswordDto
    {
        [Required]
        public string PhoneOrEmail { get; set; } = null!;

        [Required]
        public string OldPassword { get; set; } = null!;

        [Required]
        [MinLength(6)]
        public string NewPassword { get; set; } = null!;
    }
}
