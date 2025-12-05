using System.ComponentModel.DataAnnotations;
using ShoeStore.Domain.Entities;

namespace ShoeStore.Application.DTOs.Users
{
    public class UserUpdateDto
    {
        [Required]
        public long Id { get; set; }

        [Required]
        [MaxLength(250)]
        public string FullName { get; set; } = null!;

        [Required]
        [MaxLength(50)]
        public string Phone { get; set; } = null!;

        [EmailAddress]
        [MaxLength(250)]
        public string? Email { get; set; }

        public Gender Gender { get; set; }

        [Range(1, byte.MaxValue)]
        public byte RoleId { get; set; }

        public int? StoreId { get; set; }

        [Range(1, int.MaxValue)]
        public int StatusId { get; set; }
    }
}