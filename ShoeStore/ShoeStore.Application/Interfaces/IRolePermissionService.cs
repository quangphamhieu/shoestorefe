using ShoeStore.Application.DTOs.RolePermission;

namespace ShoeStore.Application.Interfaces;

public interface IRolePermissionService
{
    Task<List<RoleDto>> GetAllRolesAsync();
    Task<List<PermissionDto>> GetAllPermissionsAsync();
    Task<RolePermissionDto> GetRolePermissionsAsync(int roleId);
    Task UpdateRolePermissionsAsync(UpdateRolePermissionDto dto);
}
