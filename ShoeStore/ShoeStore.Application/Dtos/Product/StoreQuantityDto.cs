using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Product
{
    public class StoreQuantityDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int StoreId { get; set; }

        [MaxLength(250)]
        public string StoreName { get; set; } = null!;

        [Range(0, int.MaxValue)]
        public int Quantity { get; set; }

        [Range(0, double.MaxValue)]
        public decimal? SalePrice { get; set; }
    }
}
