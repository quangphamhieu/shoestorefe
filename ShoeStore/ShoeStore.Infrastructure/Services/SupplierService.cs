using AutoMapper;
using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.Dtos.Supplier;
using ShoeStore.Application.Interfaces.Services;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services
{
    public class SupplierService : ISupplierService
    {
        private readonly ShoeStoreDbContext _context;
        private readonly IMapper _mapper;

        public SupplierService(ShoeStoreDbContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public async Task<List<SupplierDto>> GetAllAsync()
        {
            var suppliers = await _context.Suppliers
                .Include(s => s.Status)
                .ToListAsync();

            return suppliers.Select(s => _mapper.Map<SupplierDto>(s)).ToList();
        }

        public async Task<SupplierDto?> GetByIdAsync(int id)
        {
            var supplier = await _context.Suppliers
                .Include(s => s.Status)
                .FirstOrDefaultAsync(s => s.Id == id);

            if (supplier == null) return null;

            return _mapper.Map<SupplierDto>(supplier);
        }

        public async Task<SupplierDto> CreateAsync(CreateSupplierDto dto)
        {
            // Validate uniqueness
            if (!string.IsNullOrWhiteSpace(dto.Code) || !string.IsNullOrWhiteSpace(dto.Name))
            {
                var exists = await _context.Suppliers.AnyAsync(s => s.Code == dto.Code || s.Name == dto.Name);
                if (exists)
                    throw new InvalidOperationException("Supplier code or name already exists.");
            }

            var supplier = _mapper.Map<Supplier>(dto);
            supplier.StatusId = 1; // Active default

            await using var txn = await _context.Database.BeginTransactionAsync();

            _context.Suppliers.Add(supplier);
            await _context.SaveChangesAsync();

            await txn.CommitAsync();

            return await GetByIdAsync(supplier.Id) ?? _mapper.Map<SupplierDto>(supplier);
        }

        public async Task<SupplierDto?> UpdateAsync(int id, UpdateSupplierDto dto)
        {
            var supplier = await _context.Suppliers.FindAsync(id);
            if (supplier == null) return null;

            // Check uniqueness if changed
            if ((!string.IsNullOrWhiteSpace(dto.Code) && dto.Code != supplier.Code) || (dto.Name != supplier.Name))
            {
                var exists = await _context.Suppliers.AnyAsync(s => (s.Code == dto.Code || s.Name == dto.Name) && s.Id != id);
                if (exists)
                    throw new InvalidOperationException("Supplier code or name already exists.");
            }

            _mapper.Map(dto, supplier);

            await _context.SaveChangesAsync();
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id)
        {
            var supplier = await _context.Suppliers.FindAsync(id);
            if (supplier == null) return false;

            _context.Suppliers.Remove(supplier);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}
