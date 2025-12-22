namespace ShoeStore.Application.DTOs.RolePermission;

public class RolePermissionDto
{
    public byte RoleId { get; set; }
    public string RoleName { get; set; } = null!;
    public string RoleCode { get; set; } = null!;
    public List<PermissionDto> Permissions { get; set; } = new();
}
