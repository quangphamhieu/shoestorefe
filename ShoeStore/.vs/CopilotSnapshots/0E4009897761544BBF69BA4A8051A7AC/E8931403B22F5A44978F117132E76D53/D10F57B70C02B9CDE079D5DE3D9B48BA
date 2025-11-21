using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Receipt
{
    public class CreateReceiptDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int SupplierId { get; set; }

        public int? StoreId { get; set; }

        [Required]
        [MinLength(1)]
        public List<CreateReceiptDetailDto> Details { get; set; } = new();
        // CreatedBy is defaulted to 1 in service (you can allow override if wanted)
    }

    public class CreateReceiptDetailDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int ProductId { get; set; }

        [Range(1, int.MaxValue)]
        public int QuantityOrdered { get; set; }
    }
}
