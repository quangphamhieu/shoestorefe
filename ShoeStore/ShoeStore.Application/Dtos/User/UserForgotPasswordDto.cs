using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.DTOs.Users
{
    public class UserForgotPasswordDto
    {
        [Required]
        public string PhoneOrEmail { get; set; } = null!;
    }
}
