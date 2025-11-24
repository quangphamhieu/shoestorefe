namespace ShoeStore.Domain.Entities;

public class RolePermission
{
    public byte RoleId { get; set; }
    public int PermissionId { get; set; }

    public Role Role { get; set; } = null!;
    public Permission Permission { get; set; } = null!;
}
