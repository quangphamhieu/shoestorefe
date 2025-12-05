using System.ComponentModel.DataAnnotations;
using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Comment;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services
{
    public class CommentService : ICommentService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public CommentService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<IEnumerable<CommentDto>> GetAllAsync()
        {
            var comments = await _context.Comments
                .AsNoTracking()
                .Include(c => c.User)
                .Include(c => c.Product)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<CommentDto>>(comments);
        }

        public async Task<IEnumerable<CommentDto>> GetByProductIdAsync(int productId)
        {
            var comments = await _context.Comments
                .AsNoTracking()
                .Include(c => c.User)
                .Include(c => c.Product)
                .Where(c => c.ProductId == productId)
                .OrderByDescending(c => c.CreatedAt)
                .ToListAsync();

            return _mapper.Map<List<CommentDto>>(comments);
        }

        public async Task<CommentDto?> GetByIdAsync(long id)
        {
            var comment = await _context.Comments
                .AsNoTracking()
                .Include(c => c.User)
                .Include(c => c.Product)
                .FirstOrDefaultAsync(c => c.Id == id);

            return comment == null ? null : _mapper.Map<CommentDto>(comment);
        }

        public async Task<CommentDto> CreateAsync(CreateCommentDto dto)
        {
            ArgumentNullException.ThrowIfNull(dto);
            ValidateRating(dto.Rating);
            var content = dto.Content?.Trim();
            if (string.IsNullOrWhiteSpace(content))
                throw new ValidationException("Content is required.");

            var userExists = await _context.Users.AsNoTracking().AnyAsync(u => u.Id == dto.UserId);
            if (!userExists)
                throw new ArgumentException("User does not exist.", nameof(dto.UserId));

            var productExists = await _context.Products.AsNoTracking().AnyAsync(p => p.Id == dto.ProductId);
            if (!productExists)
                throw new ArgumentException("Product does not exist.", nameof(dto.ProductId));

            var isDuplicated = await _context.Comments.AnyAsync(c => c.UserId == dto.UserId && c.ProductId == dto.ProductId);
            if (isDuplicated)
                throw new InvalidOperationException("User already left a review for this product.");

            var comment = new Comment
            {
                UserId = dto.UserId,
                ProductId = dto.ProductId,
                Content = content,
                Rating = dto.Rating,
                CreatedAt = DateTime.UtcNow
            };

            _context.Comments.Add(comment);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(comment.Id) ?? throw new InvalidOperationException("Failed to load the created comment.");
        }

        public async Task<CommentDto?> UpdateAsync(long id, UpdateCommentDto dto)
        {
            ArgumentNullException.ThrowIfNull(dto);
            ValidateRating(dto.Rating);
            var content = dto.Content?.Trim();
            if (string.IsNullOrWhiteSpace(content))
                throw new ValidationException("Content is required.");

            var comment = await _context.Comments.FirstOrDefaultAsync(c => c.Id == id);

            if (comment == null) return null;

            comment.Content = content;
            comment.Rating = dto.Rating;

            await _context.SaveChangesAsync();

            return await GetByIdAsync(comment.Id);
        }

        public async Task<bool> DeleteAsync(long id)
        {
            var comment = await _context.Comments.FindAsync(id);
            if (comment == null) return false;

            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();
            return true;
        }

        private static void ValidateRating(byte? rating)
        {
            if (rating.HasValue && (rating < 1 || rating > 5))
            {
                throw new ValidationException("Rating must be between 1 and 5.");
            }
        }
    }
}
