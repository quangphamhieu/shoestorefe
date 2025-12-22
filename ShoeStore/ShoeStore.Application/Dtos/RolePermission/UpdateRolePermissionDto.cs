namespace ShoeStore.Application.DTOs.RolePermission;

public class UpdateRolePermissionDto
{
    public byte RoleId { get; set; }
    public List<int> PermissionIds { get; set; } = new();
}
