namespace ShoeStore.Domain.Entities;

public class Permission
{
    public int Id { get; set; }
    public string Code { get; set; } = null!; // VD: USER_VIEW, USER_CREATE
    public string Description { get; set; } = null!;

    public ICollection<RolePermission>? RolePermissions { get; set; }
}
