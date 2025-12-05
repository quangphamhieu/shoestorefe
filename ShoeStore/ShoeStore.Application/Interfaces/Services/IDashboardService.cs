using System.Threading.Tasks;
using ShoeStore.Application.Dtos.Dashboard;

namespace ShoeStore.Application.Interfaces.Services
{
    public interface IDashboardService
    {
        Task<DashboardResponseDto> GetOverviewAsync(int? storeId, int monthCount = 6);
    }
}
