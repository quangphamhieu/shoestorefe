using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Store;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class StoreController : ControllerBase
    {
        private readonly IStoreService _storeService;

        public StoreController(IStoreService storeService)
        {
            _storeService = storeService;
        }

        [HttpGet]
        public async Task<ActionResult<List<StoreDto>>> GetAllStores()
        {
            var stores = await _storeService.GetAllAsync();
            return Ok(stores);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<StoreDto>> GetStoreById(int id)
        {
            var store = await _storeService.GetByIdAsync(id);
            return store == null ? NotFound() : Ok(store);
        }

        [HttpPost]
        [Authorize(Policy = "STORE_CREATE")]
        public async Task<ActionResult<StoreDto>> CreateStore(CreateStoreDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var store = await _storeService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetStoreById), new { id = store.Id }, store);
        }

        [HttpPut("{id}")]
        [Authorize(Policy = "STORE_UPDATE")]
        public async Task<ActionResult<StoreDto>> UpdateStore(int id, UpdateStoreDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var store = await _storeService.UpdateAsync(id, dto);
            return store == null ? NotFound() : Ok(store);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "STORE_DELETE")]
        public async Task<IActionResult> DeleteStore(int id)
        {
            var deleted = await _storeService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }
    }
}
