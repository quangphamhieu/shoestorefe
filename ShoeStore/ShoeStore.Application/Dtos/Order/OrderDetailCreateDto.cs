using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Order
{
    public class OrderDetailCreateDto
    {
        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "ProductId must be greater than zero.")]
        public int ProductId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")]
        public int Quantity { get; set; }
    }
}