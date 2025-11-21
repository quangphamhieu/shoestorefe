using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Cart;
using ShoeStore.Application.Interfaces.Services;

namespace ShoeStore.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Customer")]
    public class CartController : ControllerBase
    {
        private readonly ICartService _cartService;

        public CartController(ICartService cartService)
        {
            _cartService = cartService;
        }

        [HttpGet("getCart")]
        public async Task<IActionResult> GetCart()
        {
            var cart = await _cartService.GetCartByUserIdAsync(GetCurrentUserId());
            return Ok(cart);
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddToCart([FromBody] AddToCartRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var cart = await _cartService.AddToCartAsync(GetCurrentUserId(), request);
            return Ok(cart);
        }

        [HttpPut("update")]
        public async Task<IActionResult> UpdateQuantity([FromBody] UpdateCartItemRequest request)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var cart = await _cartService.UpdateQuantityAsync(GetCurrentUserId(), request);
            return Ok(cart);
        }

        [HttpDelete("remove/{cartItemId}")]
        public async Task<IActionResult> RemoveItem(long cartItemId)
        {
            var cart = await _cartService.RemoveItemAsync(GetCurrentUserId(), cartItemId);
            return Ok(cart);
        }

        [HttpDelete("clear")]
        public async Task<IActionResult> ClearCart()
        {
            await _cartService.ClearCartAsync(GetCurrentUserId());
            return NoContent();
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