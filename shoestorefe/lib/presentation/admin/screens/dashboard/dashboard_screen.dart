import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/dashboard.dart';
import '../../provider/dashboard_provider.dart';
import '../../provider/store_provider.dart';
import '../../widgets/app_header.dart';
import '../../widgets/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final NumberFormat _compactFormatter =
      NumberFormat.compactCurrency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final storeProvider = context.read<StoreProvider>();
      if (storeProvider.stores.isEmpty) {
        storeProvider.loadAll();
      }
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final storeProvider = context.watch<StoreProvider>();
    final summary = dashboardProvider.summary;

    return Scaffold(
      body: Row(
        children: [
          const SideMenu(),
          Expanded(
            child: Container(
              color: const Color(0xFFF5F7FA),
              child: Column(
                children: [
                  const AppHeader(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
                      child: dashboardProvider.isLoading && summary == null
                          ? const Center(child: CircularProgressIndicator())
                          : _DashboardBody(
                              summary: summary,
                              storeProvider: storeProvider,
                              dashboardProvider: dashboardProvider,
                              currencyFormatter: _currencyFormatter,
                              compactFormatter: _compactFormatter,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardSummary? summary;
  final StoreProvider storeProvider;
  final DashboardProvider dashboardProvider;
  final NumberFormat currencyFormatter;
  final NumberFormat compactFormatter;

  const _DashboardBody({
    required this.summary,
    required this.storeProvider,
    required this.dashboardProvider,
    required this.currencyFormatter,
    required this.compactFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FilterRow(
            dashboardProvider: dashboardProvider,
            storeProvider: storeProvider,
          ),
          if (dashboardProvider.error != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(message: dashboardProvider.error!),
          ],
          const SizedBox(height: 24),
          if (summary == null)
            const _EmptyState()
          else ...[
            _SummaryCards(
              summary: summary!,
              currencyFormatter: currencyFormatter,
            ),
            const SizedBox(height: 24),
            _MonthlyProfitSection(
              data: summary!.monthlyProfits,
              compactFormatter: compactFormatter,
              currencyFormatter: currencyFormatter,
            ),
            const SizedBox(height: 24),
            _TopProductsSection(
              products: summary!.topProducts,
              currencyFormatter: currencyFormatter,
            ),
            const SizedBox(height: 24),
            _BrandRankingSection(
              stats: dashboardProvider.filteredBrandStats,
              allStats: summary!.topBrands,
              dashboardProvider: dashboardProvider,
              currencyFormatter: currencyFormatter,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final DashboardProvider dashboardProvider;
  final StoreProvider storeProvider;

  const _FilterRow({
    required this.dashboardProvider,
    required this.storeProvider,
  });

  @override
  Widget build(BuildContext context) {
    final stores = storeProvider.stores;
    final brandOptions = dashboardProvider.summary?.topBrands ?? [];

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _FilterChipContainer(
          label: 'Cửa hàng',
          child: DropdownButton<int?>(
            value: dashboardProvider.selectedStoreId,
            alignment: Alignment.centerLeft,
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả cửa hàng'),
              ),
              ...stores.map(
                (store) => DropdownMenuItem<int?>(
                  value: store.id,
                  child: Text(store.name),
                ),
              ),
            ],
            onChanged: (value) =>
                dashboardProvider.loadDashboard(storeId: value),
          ),
        ),
        _FilterChipContainer(
          label: 'Hãng',
          child: DropdownButton<int?>(
            value: dashboardProvider.selectedBrandId,
            underline: const SizedBox.shrink(),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Tất cả hãng'),
              ),
              ...brandOptions
                  .where((brand) => brand.brandId != null)
                  .map(
                    (brand) => DropdownMenuItem<int?>(
                      value: brand.brandId,
                      child: Text(brand.brandName),
                    ),
                  ),
            ],
            onChanged: (value) => dashboardProvider.setBrandFilter(value),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => dashboardProvider.loadDashboard(
            storeId: dashboardProvider.selectedStoreId,
          ),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Làm mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
        ),
      ],
    );
  }
}

class _FilterChipContainer extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterChipContainer({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  final DashboardSummary summary;
  final NumberFormat currencyFormatter;

  const _SummaryCards({
    required this.summary,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final profit = summary.profitSummary;
    final growth = summary.profitGrowth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        final cards = [
          _SummaryCard(
            title: 'Doanh thu',
            value: currencyFormatter.format(profit.revenue),
            icon: Icons.bar_chart,
            color: const Color(0xFF6366F1),
          ),
          _SummaryCard(
            title: 'Giá vốn',
            value: currencyFormatter.format(profit.cost),
            icon: Icons.inventory_2,
            color: const Color(0xFF0EA5E9),
          ),
          _SummaryCard(
            title: 'Lợi nhuận',
            value: currencyFormatter.format(profit.profit),
            icon: Icons.attach_money,
            color: const Color(0xFF10B981),
          ),
          _SummaryCard(
            title: 'Tăng trưởng tháng',
            value:
                '${growth.growthPercentage >= 0 ? '+' : ''}${growth.growthPercentage.toStringAsFixed(1)}%',
            icon: growth.growthPercentage >= 0
                ? Icons.trending_up
                : Icons.trending_down,
            color: growth.growthPercentage >= 0
                ? const Color(0xFF22C55E)
                : const Color(0xFFDC2626),
            subtitle:
                'So với tháng trước (${currencyFormatter.format(growth.previousMonthProfit)})',
          ),
        ];

        if (isNarrow) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        final children = <Widget>[];
        for (var i = 0; i < cards.length; i++) {
          children.add(
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 16),
                child: cards[i],
              ),
            ),
          );
        }

        return Row(children: children);
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyProfitSection extends StatelessWidget {
  final List<MonthlyProfitStat> data;
  final NumberFormat compactFormatter;
  final NumberFormat currencyFormatter;

  const _MonthlyProfitSection({
    required this.data,
    required this.compactFormatter,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Lợi nhuận theo tháng',
      child: data.isEmpty
          ? const _EmptyPlaceholder(message: 'Chưa có dữ liệu lợi nhuận')
          : SizedBox(
              height: 260,
              child: _BarChart(
                data: data,
                compactFormatter: compactFormatter,
                currencyFormatter: currencyFormatter,
              ),
            ),
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<MonthlyProfitStat> data;
  final NumberFormat compactFormatter;
  final NumberFormat currencyFormatter;

  const _BarChart({
    required this.data,
    required this.compactFormatter,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data
        .map((e) => e.profit.abs())
        .fold<double>(0, (previousValue, element) {
      return element > previousValue ? element : previousValue;
    });
    final baseline = maxValue == 0 ? 1 : maxValue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth / (data.length * 1.6))
            .clamp(14.0, 32.0)
            .toDouble();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((entry) {
            final heightFactor = entry.profit.abs() / baseline;
            final barHeight = 170 * heightFactor;
            final isPositive = entry.profit >= 0;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    compactFormatter.format(entry.profit),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isPositive ? const Color(0xFF0F172A) : Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: barHeight,
                    width: barWidth,
                    decoration: BoxDecoration(
                      color:
                          isPositive ? const Color(0xFF2563EB) : Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${entry.month.toString().padLeft(2, '0')}/${entry.year % 100}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _TopProductsSection extends StatelessWidget {
  final List<TopProductStat> products;
  final NumberFormat currencyFormatter;

  const _TopProductsSection({
    required this.products,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Sản phẩm bán chạy',
      trailing: const Text(
        'Top 5 sản phẩm theo số lượng bán',
        style: TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
      ),
      child: products.isEmpty
          ? const _EmptyPlaceholder(message: 'Chưa có sản phẩm nào được bán')
          : DataTable(
              headingRowColor: MaterialStateProperty.all(
                const Color(0xFFF8FAFC),
              ),
              columnSpacing: 32,
              columns: const [
                DataColumn(label: Text('Sản phẩm')),
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('Số lượng')),
                DataColumn(label: Text('Doanh thu')),
              ],
              rows: products
                  .map(
                    (product) => DataRow(
                      cells: [
                        DataCell(Text(product.productName)),
                        DataCell(Text(product.sku ?? '-')),
                        DataCell(Text(product.quantitySold.toString())),
                        DataCell(
                          Text(currencyFormatter.format(product.revenue)),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _BrandRankingSection extends StatelessWidget {
  final List<BrandSalesStat> stats;
  final List<BrandSalesStat> allStats;
  final DashboardProvider dashboardProvider;
  final NumberFormat currencyFormatter;

  const _BrandRankingSection({
    required this.stats,
    required this.allStats,
    required this.dashboardProvider,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Hiệu suất theo hãng',
      trailing: Text(
        'Tổng số hãng: ${allStats.length}',
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 13,
        ),
      ),
      child: stats.isEmpty
          ? const _EmptyPlaceholder(message: 'Chưa có dữ liệu hãng sản phẩm')
          : Wrap(
              spacing: 16,
              runSpacing: 16,
              children: stats
                  .map(
                    (brand) => _BrandCard(
                      brand: brand,
                      isActive:
                          dashboardProvider.selectedBrandId == brand.brandId,
                    onTap: () {
                      if (dashboardProvider.selectedBrandId == brand.brandId) {
                        dashboardProvider.setBrandFilter(null);
                      } else {
                        dashboardProvider.setBrandFilter(brand.brandId);
                      }
                    },
                      currencyFormatter: currencyFormatter,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandSalesStat brand;
  final bool isActive;
  final VoidCallback onTap;
  final NumberFormat currencyFormatter;

  const _BrandCard({
    required this.brand,
    required this.isActive,
    required this.onTap,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        width: 240,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEEF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : Colors.grey.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brand.brandName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đã bán: ${brand.quantitySold}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Doanh thu: ${currencyFormatter.format(brand.revenue)}',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionContainer({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 26,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: const _EmptyPlaceholder(
        message: 'Chưa có dữ liệu để hiển thị. Vui lòng thử lại sau.',
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final String message;

  const _EmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.insert_chart_outlined, size: 48, color: Colors.grey[400]),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
