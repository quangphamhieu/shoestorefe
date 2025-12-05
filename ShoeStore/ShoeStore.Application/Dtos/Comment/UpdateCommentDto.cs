using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Comment
{
    public class UpdateCommentDto
    {
        [Required]
        [StringLength(2000, MinimumLength = 3)]
        public string Content { get; set; } = null!;

        [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5.")]
        public byte? Rating { get; set; }
    }
}
