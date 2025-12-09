using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Order
{
    public class OrderInfoUpdateDto
    {
        [Required]
        public long OrderId { get; set; }

        public string? Note { get; set; }

        public string? Address { get; set; }
    }
}
