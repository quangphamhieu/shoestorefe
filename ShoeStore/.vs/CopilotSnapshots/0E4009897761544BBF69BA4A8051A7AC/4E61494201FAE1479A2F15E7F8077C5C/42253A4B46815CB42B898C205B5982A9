using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Product
{
    public class CreateProductDto
    {
        [Required]
        [MaxLength(500)]
        public string? Name { get; set; }

        public int? BrandId { get; set; }
        public int? SupplierId { get; set; }

        [Range(0, double.MaxValue)]
        public decimal CostPrice { get; set; }

        [Range(0, double.MaxValue)]
        public decimal OriginalPrice { get; set; }

        [MaxLength(100)]
        public string? Color { get; set; }

        [MaxLength(100)]
        public string? Size { get; set; }

        [MaxLength(2000)]
        public string? Description { get; set; }

        [MaxLength(1000)]
        public string? ImageUrl { get; set; }
        public IFormFile? ImageFile { get; set; }
        public int StatusId { get; set; }
    }
}
