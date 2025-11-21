using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Brand;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services
{
    public class BrandService : IBrandService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public BrandService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<BrandDto>> GetAllAsync()
        {
            var brands = await _context.Brands.ToListAsync();
            return brands.Select(b => _mapper.Map<BrandDto>(b)).ToList();
        }

        public async Task<BrandDto?> GetByIdAsync(int id)
        {
            var brand = await _context.Brands.FindAsync(id);
            if (brand == null) return null;

            return _mapper.Map<BrandDto>(brand);
        }

        public async Task<BrandDto> CreateAsync(CreateBrandDto dto)
        {
            // Validate business rule: unique Code or Name
            if (!string.IsNullOrWhiteSpace(dto.Code) || !string.IsNullOrWhiteSpace(dto.Name))
            {
                var exists = await _context.Brands.AnyAsync(b => b.Code == dto.Code || b.Name == dto.Name);
                if (exists)
                    throw new InvalidOperationException("Brand code or name already exists.");
            }

            var brand = _mapper.Map<Brand>(dto);
            brand.StatusId = 1; // Mặc định Active

            // Use transaction to be safe if extended later
            await using var txn = await _context.Database.BeginTransactionAsync();

            _context.Brands.Add(brand);
            await _context.SaveChangesAsync();

            await txn.CommitAsync();

            return _mapper.Map<BrandDto>(brand);
        }

        public async Task<BrandDto?> UpdateAsync(int id, UpdateBrandDto dto)
        {
            var brand = await _context.Brands.FindAsync(id);
            if (brand == null) return null;

            // Check uniqueness if name/code changed
            if ((!string.IsNullOrWhiteSpace(dto.Code) && dto.Code != brand.Code) || (dto.Name != brand.Name))
            {
                var exists = await _context.Brands.AnyAsync(b => (b.Code == dto.Code || b.Name == dto.Name) && b.Id != id);
                if (exists)
                    throw new InvalidOperationException("Brand code or name already exists.");
            }

            _mapper.Map(dto, brand);

            await _context.SaveChangesAsync();

            return _mapper.Map<BrandDto>(brand);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var brand = await _context.Brands.FindAsync(id);
            if (brand == null) return false;

            _context.Brands.Remove(brand);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
