using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Store;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services
{
    public class StoreService : IStoreService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public StoreService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<StoreDto>> GetAllAsync()
        {
            var stores = await _context.Stores
                .Include(s => s.Status)
                .ToListAsync();

            return stores.Select(s => _mapper.Map<StoreDto>(s)).ToList();
        }

        public async Task<StoreDto?> GetByIdAsync(int id)
        {
            var store = await _context.Stores
                .Include(s => s.Status)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (store == null) return null;

            return _mapper.Map<StoreDto>(store);
        }

        public async Task<StoreDto> CreateAsync(CreateStoreDto dto)
        {
            // Validate uniqueness
            if (!string.IsNullOrWhiteSpace(dto.Code) || !string.IsNullOrWhiteSpace(dto.Name))
            {
                var exists = await _context.Stores.AnyAsync(s => s.Code == dto.Code || s.Name == dto.Name);
                if (exists)
                    throw new InvalidOperationException("Store code or name already exists.");
            }

            var store = _mapper.Map<Store>(dto);
            store.StatusId = 1; // mặc định active

            await using var txn = await _context.Database.BeginTransactionAsync();

            _context.Stores.Add(store);
            await _context.SaveChangesAsync();

            await txn.CommitAsync();

            return await GetByIdAsync(store.Id) ?? _mapper.Map<StoreDto>(store);
        }

        public async Task<StoreDto?> UpdateAsync(int id, UpdateStoreDto dto)
        {
            var store = await _context.Stores.FindAsync(id);
            if (store == null) return null;

            // Check uniqueness if changed
            if ((!string.IsNullOrWhiteSpace(dto.Code) && dto.Code != store.Code) || (dto.Name != store.Name))
            {
                var exists = await _context.Stores.AnyAsync(s => (s.Code == dto.Code || s.Name == dto.Name) && s.Id != id);
                if (exists)
                    throw new InvalidOperationException("Store code or name already exists.");
            }

            _mapper.Map(dto, store);

            await _context.SaveChangesAsync();
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var store = await _context.Stores.FindAsync(id);
            if (store == null) return false;

            _context.Stores.Remove(store);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
