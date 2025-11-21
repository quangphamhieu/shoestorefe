using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Promotion
{
    public class UpdatePromotionDto
    {
        [Required]
        [MaxLength(300)]
        public string Name { get; set; } = null!;

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        public int StatusId { get; set; }

        public List<UpdatePromotionProductDto>? Products { get; set; }
        public List<PromotionStoreDto>? Stores { get; set; }

    }

    public class UpdatePromotionProductDto
    {
        [Required]
        [Range(1, int.MaxValue)]
        public int ProductId { get; set; }

        [Range(0, 100)]
        public decimal DiscountPercent { get; set; }
    }
}
