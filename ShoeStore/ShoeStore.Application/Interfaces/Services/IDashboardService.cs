public interface IDashboardService
{
    Task<DashboardDto> GetDashboardAsync(DashboardFilterDto filter);
}
