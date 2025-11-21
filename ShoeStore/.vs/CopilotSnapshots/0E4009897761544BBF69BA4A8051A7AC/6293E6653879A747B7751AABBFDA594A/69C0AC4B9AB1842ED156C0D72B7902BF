using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Brand
{
    public class CreateBrandDto
    {
        [MaxLength(50)]
        public string? Code { get; set; }

        [Required]
        [MaxLength(200)]
        public string Name { get; set; } = null!;

        [MaxLength(1000)]
        public string? Description { get; set; }
    }
}
