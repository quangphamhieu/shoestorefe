using Microsoft.EntityFrameworkCore;
using ShoeStore.Application.DTOs.RolePermission;
using ShoeStore.Application.Interfaces;
using ShoeStore.Domain.Entities;
using ShoeStore.Infrastructure.Persistence;

namespace ShoeStore.Infrastructure.Services;

public class RolePermissionService : IRolePermissionService
{
    private readonly ShoeStoreDbContext _context;

    public RolePermissionService(ShoeStoreDbContext context)
    {
        _context = context;
    }

    public async Task<List<RoleDto>> GetAllRolesAsync()
    {
        return await _context.Roles
            .Select(r => new RoleDto
            {
                Id = r.Id,
                Name = r.Name,
                Code = r.Code
            })
            .ToListAsync();
    }

    public async Task<List<PermissionDto>> GetAllPermissionsAsync()
    {
        return await _context.Permissions
            .Select(p => new PermissionDto
            {
                Id = p.Id,
                Code = p.Code,
                Description = p.Description
            })
            .ToListAsync();
    }

    public async Task<RolePermissionDto> GetRolePermissionsAsync(int roleId)
    {
        var role = await _context.Roles
            .Include(r => r.RolePermissions!)
            .ThenInclude(rp => rp.Permission)
            .FirstOrDefaultAsync(r => r.Id == roleId);

        if (role == null)
            throw new Exception("Role not found");

        return new RolePermissionDto
        {
            RoleId = role.Id,
            RoleName = role.Name,
            RoleCode = role.Code,
            Permissions = role.RolePermissions?.Select(rp => new PermissionDto
            {
                Id = rp.Permission.Id,
                Code = rp.Permission.Code,
                Description = rp.Permission.Description
            }).ToList() ?? new List<PermissionDto>()
        };
    }

    public async Task UpdateRolePermissionsAsync(UpdateRolePermissionDto dto)
    {
        var role = await _context.Roles
            .Include(r => r.RolePermissions)
            .FirstOrDefaultAsync(r => r.Id == dto.RoleId);

        if (role == null)
            throw new Exception("Role not found");

        var currentPermissionIds = role.RolePermissions?.Select(rp => rp.PermissionId).ToList() ?? new List<int>();
        var newPermissionIds = dto.PermissionIds;

        var permissionsToAdd = newPermissionIds.Except(currentPermissionIds).ToList();
        var permissionsToRemove = currentPermissionIds.Except(newPermissionIds).ToList();

        if (permissionsToRemove.Any())
        {
            var toRemove = role.RolePermissions?
                .Where(rp => permissionsToRemove.Contains(rp.PermissionId))
                .ToList();
            
            if (toRemove != null)
            {
                _context.RolePermissions.RemoveRange(toRemove);
            }
        }

        if (permissionsToAdd.Any())
        {
            foreach (var permissionId in permissionsToAdd)
            {
                _context.RolePermissions.Add(new RolePermission
                {
                    RoleId = dto.RoleId,
                    PermissionId = permissionId
                });
            }
        }

        await _context.SaveChangesAsync();
    }
}
