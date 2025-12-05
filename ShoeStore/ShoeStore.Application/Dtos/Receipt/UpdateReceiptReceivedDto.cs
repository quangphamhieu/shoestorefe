using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Receipt
{
    public class UpdateReceiptReceivedDto
    {
        // toàn bộ danh sách detail cập nhật ReceivedQuantity
        [Required]
        [MinLength(1)]
        public List<UpdateReceivedDetailDto> Details { get; set; } = new();
    }

    public class UpdateReceivedDetailDto
    {
        [Required]
        public long ReceiptDetailId { get; set; } // hoặc ProductId -> dùng ReceiptDetailId an toàn hơn

        [Range(0, int.MaxValue)]
        public int ReceivedQuantity { get; set; }
    }
}
