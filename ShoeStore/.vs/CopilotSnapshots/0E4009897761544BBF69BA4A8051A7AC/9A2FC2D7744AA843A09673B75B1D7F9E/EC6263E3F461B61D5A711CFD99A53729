using System.ComponentModel.DataAnnotations;

namespace ShoeStore.Application.Dtos.Notification
{
    public class CreateNotificationDto
    {
        [Required]
        [MaxLength(300)]
        public string Title { get; set; } = null!;

        [Required]
        [MaxLength(4000)]
        public string Message { get; set; } = null!;

        [MaxLength(100)]
        public string? Type { get; set; }
    }
}
