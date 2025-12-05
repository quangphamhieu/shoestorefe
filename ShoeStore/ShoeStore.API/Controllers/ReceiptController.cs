using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Receipt;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReceiptsController : ControllerBase
    {
        private readonly IReceiptService _receiptService;

        public ReceiptsController(IReceiptService receiptService)
        {
            _receiptService = receiptService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<ReceiptDto>>> GetAll()
        {
            var receipts = await _receiptService.GetAllAsync();
            return Ok(receipts);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<ReceiptDto>> GetById(long id)
        {
            var receipt = await _receiptService.GetByIdAsync(id);
            return receipt == null ? NotFound() : Ok(receipt);
        }

        [HttpPost]
        [Authorize(Policy = "RECEIPT_CREATE")]
        public async Task<ActionResult<ReceiptDto>> Create(CreateReceiptDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _receiptService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}/info")]
        [Authorize(Policy = "RECEIPT_UPDATE")]
        public async Task<ActionResult<ReceiptDto>> UpdateInfo(long id, UpdateReceiptDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _receiptService.UpdateAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        [HttpPut("{id}/receive")]
        [Authorize(Policy = "RECEIPT_UPDATE")]
        public async Task<ActionResult<ReceiptDto>> UpdateReceived(long id, UpdateReceiptReceivedDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _receiptService.UpdateReceivedAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        // ✅ Thêm endpoint xóa
        [HttpDelete("{id}")]
        [Authorize(Policy = "RECEIPT_DELETE")]
        public async Task<IActionResult> Delete(long id)
        {
            var deleted = await _receiptService.DeleteAsync(id);
            if (!deleted) return NotFound();

            return NoContent(); // HTTP 204
        }
    }
}
