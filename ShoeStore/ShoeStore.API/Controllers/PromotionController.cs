using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Promotion;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PromotionController : ControllerBase
    {
        private readonly IPromotionService _promotionService;

        public PromotionController(IPromotionService promotionService)
        {
            _promotionService = promotionService;
        }

        [HttpGet]
        public async Task<ActionResult<List<PromotionDto>>> GetAll()
        {
            var promotions = await _promotionService.GetAllAsync();
            return Ok(promotions);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PromotionDto>> GetById(int id)
        {
            var promotion = await _promotionService.GetByIdAsync(id);
            return promotion == null ? NotFound() : Ok(promotion);
        }

        [HttpPost]
        [Authorize(Policy = "PROMOTION_CREATE")]
        public async Task<ActionResult<PromotionDto>> Create([FromBody] CreatePromotionDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _promotionService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "PROMOTION_UPDATE")]
        public async Task<ActionResult<PromotionDto>> Update(int id, [FromBody] UpdatePromotionDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _promotionService.UpdateAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "PROMOTION_DELETE")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _promotionService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
