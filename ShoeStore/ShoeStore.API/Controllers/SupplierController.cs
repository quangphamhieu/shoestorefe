using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Supplier;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SupplierController : ControllerBase
    {
        private readonly ISupplierService _supplierService;

        public SupplierController(ISupplierService supplierService)
        {
            _supplierService = supplierService;
        }

        [HttpGet]
        public async Task<ActionResult<List<SupplierDto>>> GetAllSuppliers()
        {
            var suppliers = await _supplierService.GetAllAsync();
            return Ok(suppliers);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<SupplierDto>> GetSupplierById(int id)
        {
            var supplier = await _supplierService.GetByIdAsync(id);
            return supplier == null ? NotFound() : Ok(supplier);
        }

        [HttpPost]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult<SupplierDto>> CreateSupplier(CreateSupplierDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var supplier = await _supplierService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetSupplierById), new { id = supplier.Id }, supplier);
        }

        [HttpPut("{id}")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult<SupplierDto>> UpdateSupplier(int id, UpdateSupplierDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var supplier = await _supplierService.UpdateAsync(id, dto);
            return supplier == null ? NotFound() : Ok(supplier);
        }

        [HttpDelete("{id}")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<IActionResult> DeleteSupplier(int id)
        {
            var deleted = await _supplierService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
