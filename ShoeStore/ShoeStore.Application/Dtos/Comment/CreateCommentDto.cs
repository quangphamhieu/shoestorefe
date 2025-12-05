using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Comment
{
    public class CreateCommentDto
    {
        [Required]
        [Range(1, long.MaxValue, ErrorMessage = "UserId must be greater than zero.")]
        public long UserId { get; set; }

        [Required]
        [Range(1, int.MaxValue, ErrorMessage = "ProductId must be greater than zero.")]
        public int ProductId { get; set; }

        [Required]
        [StringLength(2000, MinimumLength = 3)]
        public string Content { get; set; } = null!;

        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public byte? Rating { get; set; }
    }
}
