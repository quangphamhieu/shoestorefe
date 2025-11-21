using System.ComponentModel.DataAnnotations;
using ShoeStore.Domain.Entities;

namespace ShoeStore.Application.Dtos.Order
{
    public class OrderCreateDto
    {
        [Required]
        [Range(1, long.MaxValue, ErrorMessage = "CustomerId must be greater than zero.")]
        public long CustomerId { get; set; }

        [Required]
        [EnumDataType(typeof(OrderType))]
        public OrderType OrderType { get; set; }

        [Required]
        [EnumDataType(typeof(PaymentMethod))]
        public PaymentMethod PaymentMethod { get; set; }

        /// <summary>
        /// Offline orders require StoreId (store of the staff creating the order).
        /// Online orders ignore this value and will automatically use the warehouse store (Id = 1).
        /// </summary>
        [Range(1, int.MaxValue, ErrorMessage = "StoreId must be greater than zero.")]
        public int? StoreId { get; set; }

        [Required]
        [MinLength(1, ErrorMessage = "Order must contain at least one detail.")]
        public List<OrderDetailCreateDto> Details { get; set; } = new();
    }
}