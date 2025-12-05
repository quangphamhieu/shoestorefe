using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Store
{
    public class UpdateStoreDto
    {
        [MaxLength(50)]
        public string? Code { get; set; }

        [Required]
        [MaxLength(250)]
        public string Name { get; set; } = null!;

        [MaxLength(500)]
        public string? Address { get; set; }

        [MaxLength(50)]
        public string? Phone { get; set; }

        public int StatusId { get; set; }
    }
}
