using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Order
{
    public class OrderStatusUpdateDto
    {
        [Required]
        [Range(1, long.MaxValue, ErrorMessage = "OrderId must be greater than zero.")]
        public long OrderId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "StatusId must be greater than zero.")]
        public int StatusId { get; set; }
    }
}
