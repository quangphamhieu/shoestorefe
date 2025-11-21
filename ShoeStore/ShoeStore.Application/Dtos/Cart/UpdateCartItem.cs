using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Cart
{
    public class UpdateCartItemRequest
    {
        [Required]
        [Range(1, long.MaxValue, ErrorMessage = "Cart item id must be greater than zero.")]
        public long CartItemId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "Quantity must be at least 1.")]
        public int Quantity { get; set; }
    }
}