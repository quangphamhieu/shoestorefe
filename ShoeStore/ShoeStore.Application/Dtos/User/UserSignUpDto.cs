using System.ComponentModel.DataAnnotations;
using ShoeStore.Domain.Entities;

namespace ShoeStore.Application.DTOs.Users
{
    public class UserSignUpDto
    {
        [Required]
        [MaxLength(250)]
        public string FullName { get; set; } = null!;

        [Required]
        [MaxLength(50)]
        public string Phone { get; set; } = null!;

        [EmailAddress]
        [MaxLength(250)]
        public string? Email { get; set; }

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = null!;

        public Gender Gender { get; set; }
    }
}