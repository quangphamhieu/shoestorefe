using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Cart;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services
{
    public class CartService : ICartService
    {
        private const int DefaultStoreId = 1;
        private const int ActiveStatusId = 1;

        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public CartService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<CartDto> GetCartByUserIdAsync(long userId)
        {
            var cart = await _context.Carts
                .AsNoTracking()
                .Include(c => c.CartItems)
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null)
                return new CartDto { UserId = userId };

            return _mapper.Map<CartDto>(cart);
        }

        public async Task<CartDto> AddToCartAsync(long userId, AddToCartRequest request)
        {
            ArgumentNullException.ThrowIfNull(request);
            EnsurePositiveQuantity(request.Quantity, nameof(request.Quantity));

            await EnsureUserExistsAsync(userId);

            var product = await _context.Products
                .AsNoTracking()
                .FirstOrDefaultAsync(p => p.Id == request.ProductId)
                ?? throw new ArgumentException("Product does not exist.", nameof(request.ProductId));

            if (product.StatusId != ActiveStatusId)
                throw new InvalidOperationException("Product is not available for sale.");

            var storeProduct = await LoadStoreProductAsync(request.ProductId);
            EnsureStockAvailable(storeProduct.Quantity, request.Quantity, product.Name);

            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart == null)
            {
                cart = new Cart
                {
                    UserId = userId,
                    StatusId = ActiveStatusId,
                    CreatedAt = DateTime.UtcNow,
                    CartItems = new List<CartItem>()
                };
                _context.Carts.Add(cart);
            }

            cart.CartItems ??= new List<CartItem>();

            var existingItem = cart.CartItems.FirstOrDefault(i => i.ProductId == request.ProductId);
            if (existingItem != null)
            {
                var newQuantity = existingItem.Quantity + request.Quantity;
                EnsureStockAvailable(storeProduct.Quantity, newQuantity, product.Name);
                existingItem.Quantity = newQuantity;
                existingItem.UnitPrice = storeProduct.SalePrice;
            }
            else
            {
                cart.CartItems.Add(new CartItem
                {
                    ProductId = product.Id,
                    Quantity = request.Quantity,
                    UnitPrice = storeProduct.SalePrice
                });
            }

            await _context.SaveChangesAsync();
            return await GetCartByUserIdAsync(userId);
        }

        public async Task<CartDto> UpdateQuantityAsync(long userId, UpdateCartItemRequest request)
        {
            ArgumentNullException.ThrowIfNull(request);
            EnsurePositiveQuantity(request.Quantity, nameof(request.Quantity));

            var cart = await _context.Carts
                .Include(c => c.CartItems)!
                    .ThenInclude(ci => ci.Product)
                .FirstOrDefaultAsync(c => c.UserId == userId)
                ?? throw new KeyNotFoundException("Cart does not exist.");

            var item = cart.CartItems?.FirstOrDefault(i => i.Id == request.CartItemId)
                ?? throw new KeyNotFoundException("Cart item does not exist.");

            var storeProduct = await LoadStoreProductAsync(item.ProductId);
            EnsureStockAvailable(storeProduct.Quantity, request.Quantity, item.Product?.Name ?? "product");

            item.Quantity = request.Quantity;

            await _context.SaveChangesAsync();

            return await GetCartByUserIdAsync(userId);
        }

        public async Task<CartDto> RemoveItemAsync(long userId, long cartItemId)
        {
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .FirstOrDefaultAsync(c => c.UserId == userId)
                ?? throw new KeyNotFoundException("Cart does not exist.");

            var item = cart.CartItems?.FirstOrDefault(i => i.Id == cartItemId)
                ?? throw new KeyNotFoundException("Cart item does not exist.");

            _context.CartItems.Remove(item);
            await _context.SaveChangesAsync();

            return await GetCartByUserIdAsync(userId);
        }

        public async Task ClearCartAsync(long userId)
        {
            var cart = await _context.Carts
                .Include(c => c.CartItems)
                .FirstOrDefaultAsync(c => c.UserId == userId);

            if (cart?.CartItems == null || !cart.CartItems.Any())
                return;

            _context.CartItems.RemoveRange(cart.CartItems);
            await _context.SaveChangesAsync();
        }

        private async Task EnsureUserExistsAsync(long userId)
        {
            var exists = await _context.Users.AsNoTracking().AnyAsync(u => u.Id == userId);
            if (!exists)
                throw new UnauthorizedAccessException("User does not exist.");
        }

        private static void EnsurePositiveQuantity(int quantity, string parameterName)
        {
            if (quantity <= 0)
                throw new ValidationException($"{parameterName} must be greater than zero.");
        }

        private static void EnsureStockAvailable(int available, int requested, string productName)
        {
            if (requested > available)
                throw new InvalidOperationException($"Product '{productName}' only has {available} units available.");
        }

        private async Task<StoreProduct> LoadStoreProductAsync(int productId)
        {
            return await _context.StoreProducts
                .FirstOrDefaultAsync(sp => sp.ProductId == productId && sp.StoreId == DefaultStoreId)
                ?? throw new InvalidOperationException("Product is not available in the default store inventory.");
        }
    }
}
