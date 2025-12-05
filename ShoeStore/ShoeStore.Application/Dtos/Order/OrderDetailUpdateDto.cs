using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Order
{
    public class OrderDetailUpdateDto
    {
        [Required]
        [Range(1, long.MaxValue, ErrorMessage = "OrderDetailId must be greater than zero.")]
        public long OrderDetailId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")]
        public int Quantity { get; set; }
    }
}