using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Receipt
{
    public class UpdateReceiptDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int SupplierId { get; set; }

        public int? StoreId { get; set; }

        [Required]
        [MinLength(1)]
        public List<UpdateReceiptDetailDto> Details { get; set; } = new();
    }

    public class UpdateReceiptDetailDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int ProductId { get; set; }

        [Range(1, int.MaxValue)]
        public int QuantityOrdered { get; set; }
    }
}
