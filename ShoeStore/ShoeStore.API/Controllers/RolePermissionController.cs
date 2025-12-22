using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.DTOs.RolePermission;
using ShoeStore.Application.Interfaces;

namespace ShoeStore.API.Controllers;

[Route("api/[controller]")]
[ApiController]
//[Authorize(Policy = "ROLE_MANAGE")]
public class RolePermissionController : ControllerBase
{
    private readonly IRolePermissionService _rolePermissionService;

    public RolePermissionController(IRolePermissionService rolePermissionService)
    {
        _rolePermissionService = rolePermissionService;
    }

    [HttpGet("roles")]
    public async Task<IActionResult> GetAllRoles()
    {
        var roles = await _rolePermissionService.GetAllRolesAsync();
        return Ok(roles);
    }

    [HttpGet("permissions")]
    public async Task<IActionResult> GetAllPermissions()
    {
        var permissions = await _rolePermissionService.GetAllPermissionsAsync();
        return Ok(permissions);
    }

    [HttpGet("{roleId}")]
    public async Task<IActionResult> GetRolePermissions(int roleId)
    {
        try
        {
            var rolePermissions = await _rolePermissionService.GetRolePermissionsAsync(roleId);
            return Ok(rolePermissions);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPut]
    public async Task<IActionResult> UpdateRolePermissions([FromBody] UpdateRolePermissionDto dto)
    {
        try
        {
            await _rolePermissionService.UpdateRolePermissionsAsync(dto);
            return Ok(new { message = "Role permissions updated successfully" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
