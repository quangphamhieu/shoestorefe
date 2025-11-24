using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Product;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductsController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductsController(IProductService productService)
        {
            _productService = productService;
        }

        [HttpGet]
        [Authorize(Policy = "PRODUCT_VIEW")]

        public async Task<ActionResult<List<ProductDto>>> GetAll()
        {
            var products = await _productService.GetAllAsync();
            return Ok(products);
        }

        [HttpGet("{id}")]
        [Authorize(Policy = "PRODUCT_VIEW")]
        public async Task<ActionResult<ProductDto>> GetById(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            return product == null ? NotFound() : Ok(product);
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        [Authorize(Policy ="PRODUCT_CREATE")]
        public async Task<ActionResult<ProductDto>> Create(CreateProductDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var created = await _productService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = created.Id }, created);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        [Authorize(Policy = "PRODUCT_UPDATE")]
        public async Task<ActionResult<ProductDto>> Update(int id, UpdateProductDto dto)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var updated = await _productService.UpdateAsync(id, dto);
            return updated == null ? NotFound() : Ok(updated);
        }

        [HttpDelete("{id}")]
        [Authorize(Policy = "PRODUCT_DELETE")]
        public async Task<ActionResult> Delete(int id)
        {
            var deleted = await _productService.DeleteAsync(id);
            return deleted ? NoContent() : NotFound();
        }

        [HttpPost("search")]
        public async Task<ActionResult> Search([FromBody] SearchProductDto searchDto)
        {
            var result = await _productService.SearchAsync(searchDto);
            return Ok(result);
        }

        [HttpGet("suggest")]
        public async Task<ActionResult> Suggest([FromQuery] string keyword)
        {
            if (string.IsNullOrWhiteSpace(keyword))
                return Ok(Enumerable.Empty<string>());

            var suggestions = await _productService.SuggestAsync(keyword);
            return Ok(suggestions);
        }

        [HttpPost("{productId}/store-quantity")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult> CreateStoreQuantity(int productId, [FromBody] StoreQuantityDto dto)
        {
            if (dto == null || dto.StoreId <= 0)
                return BadRequest(new { message = "Invalid StoreQuantityDto" });

            var created = await _productService.CreateStoreQuantityAsync(dto, productId);
            return created == null
                ? Conflict(new { message = "Relation already exists." })
                : Ok(created);
        }

        [HttpPut("{productId}/store-quantity")]
        [Authorize(Roles = "Super Admin, Admin")]
        public async Task<ActionResult> UpdateStoreQuantity(int productId, [FromBody] StoreQuantityDto dto)
        {
            if (dto == null || dto.StoreId <= 0)
                return BadRequest(new { message = "Invalid StoreQuantityDto" });

            var updated = await _productService.UpdateStoreQuantityAsync(dto, productId);
            return updated == null
                ? NotFound(new { message = $"No relation found for ProductId {productId} and StoreId {dto.StoreId}." })
                : Ok(updated);
        }
    }
}
