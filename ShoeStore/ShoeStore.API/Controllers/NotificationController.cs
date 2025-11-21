using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Notification;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class NotificationsController : ControllerBase
    {
        private readonly INotificationService _notificationService;

        public NotificationsController(INotificationService notificationService)
        {
            _notificationService = notificationService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<NotificationDto>>> GetAll()
        {
            var list = await _notificationService.GetAllAsync();
            return Ok(list);
        }

        [HttpGet("{id:long}")]
        public async Task<ActionResult<NotificationDto>> GetById(long id)
        {
            var item = await _notificationService.GetByIdAsync(id);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult<NotificationDto>> Create(CreateNotificationDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _notificationService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpDelete("{id:long}")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult> Delete(long id)
        {
            var deleted = await _notificationService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
