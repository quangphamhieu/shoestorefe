using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Supplier
{
    public class UpdateSupplierDto
    {
        [MaxLength(50)]
        public string? Code { get; set; }

        [Required]
        [MaxLength(250)]
        public string Name { get; set; } = null!;

        [MaxLength(1000)]
        public string? ContactInfo { get; set; }

        public int StatusId { get; set; }
    }
}
