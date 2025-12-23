using Microsoft.AspNetCore.Mvc;
using ShoeStore.Application.Dtos.Dashboard;
using ShoeStore.Application.Interfaces.Services;
using System.Threading.Tasks;

namespace ShoeStore.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet]
        public async Task<ActionResult<DashboardResponseDto>> Get([FromQuery] int? storeId, [FromQuery] int? brandId, [FromQuery] int months = 6)
        {
            if (months <= 0)
            {
                months = 6;
            }

            var result = await _dashboardService.GetOverviewAsync(storeId, brandId, months);
            return Ok(result);
        }
    }
}

