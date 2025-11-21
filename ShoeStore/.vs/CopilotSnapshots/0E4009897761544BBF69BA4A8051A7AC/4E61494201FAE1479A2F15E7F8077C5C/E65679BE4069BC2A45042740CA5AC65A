using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Brand;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BrandsController : ControllerBase
    {
        private readonly IBrandService _brandService;

        public BrandsController(IBrandService brandService)
        {
            _brandService = brandService;
        }

        [HttpGet]
        public async Task<ActionResult<List<BrandDto>>> GetAll()
        {
            var brands = await _brandService.GetAllAsync();
            return Ok(brands);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<BrandDto>> GetById(int id)
        {
            var brand = await _brandService.GetByIdAsync(id);
            return brand == null ? NotFound() : Ok(brand);
        }

        [HttpPost]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult<BrandDto>> Create(CreateBrandDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _brandService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult<BrandDto>> Update(int id, UpdateBrandDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _brandService.UpdateAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _brandService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
