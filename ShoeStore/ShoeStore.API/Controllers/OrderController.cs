using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Order;
using ShoeStore.Application.Interfaces.Services;
using System.Threading.Tasks;

namespace ShoeStore.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrderController : ControllerBase
    {
        private readonly IOrderService _service;

        public OrderController(IOrderService service)
        {
            _service = service;
        }

        [HttpPost]
        [Authorize(Roles = "Customer,Super Admin,Admin,Staff")]
        public async Task<IActionResult> Create([FromBody] OrderCreateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var result = await _service.CreateOrderAsync(dto, GetCurrentUserId());
            return CreatedAtAction(nameof(Get), new { id = result.Id }, result);
        }

        [HttpGet("{id}")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<IActionResult> Get(long id)
        {
            var result = await _service.GetOrderByIdAsync(id);
            return result != null ? Ok(result) : NotFound();
        }

        [HttpGet]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<IActionResult> GetAll()
        {
            var result = await _service.GetAllOrdersAsync();
            return Ok(result);
        }

        [HttpGet("myOrder")]
        [Authorize(Roles = "Customer,Super Admin,Admin,Staff")]
        public async Task<IActionResult> GetOrderByUser()
        {
            var result = await _service.GetOrderByUserAsync(GetCurrentUserId());
            return Ok(result);
        }

        [HttpPut("detail/{orderDetailId:long}")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<IActionResult> UpdateDetail(long orderDetailId, [FromBody] OrderDetailUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            dto.OrderDetailId = orderDetailId;
            var success = await _service.UpdateOrderDetailAsync(dto);
            return success ? Ok() : NotFound();
        }

        [HttpDelete("detail/{orderDetailId:long}")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<IActionResult> DeleteDetail(long orderDetailId)
        {
            var success = await _service.DeleteOrderDetailAsync(orderDetailId);
            return success ? Ok() : NotFound();
        }

        [HttpPut("status")]
        [Authorize(Roles = "Super Admin,Admin,Staff")]
        public async Task<IActionResult> UpdateStatus([FromBody] OrderStatusUpdateDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var success = await _service.UpdateOrderStatusAsync(dto);
            return success ? Ok() : NotFound();
        }

        private long GetCurrentUserId()
        {
            var claimValue = User.FindFirst("userId")?.Value
                ?? throw new UnauthorizedAccessException("Missing user id claim.");

            return long.TryParse(claimValue, out var userId)
                ? userId
                : throw new UnauthorizedAccessException("Invalid user id claim.");
        }
    }
}
