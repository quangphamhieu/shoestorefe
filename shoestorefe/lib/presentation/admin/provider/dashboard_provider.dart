import 'package:flutter/material.dart';
import '../../../domain/entities/dashboard.dart';
import '../../../domain/usecases/dashboard/get_dashboard_overview_usecase.dart';

class DashboardProvider extends ChangeNotifier {
  final GetDashboardOverviewUseCase getDashboardOverviewUseCase;

  DashboardSummary? _summary;
  bool _isLoading = false;
  String? _error;
  int? _selectedStoreId;
  int? _selectedBrandId;
  int _months = 6;

  DashboardProvider(this.getDashboardOverviewUseCase);

  DashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedStoreId => _selectedStoreId;
  int? get selectedBrandId => _selectedBrandId;
  int get months => _months;

  Future<void> loadDashboard({int? storeId, int? months}) async {
    _selectedStoreId = storeId;
    _selectedBrandId = null;
    if (months != null && months > 0) {
      _months = months;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await getDashboardOverviewUseCase.call(
        storeId: _selectedStoreId,
        months: _months,
      );

      final brands = _summary?.topBrands ?? [];
      if (brands.isEmpty) {
        _selectedBrandId = null;
      } else if (_selectedBrandId != null &&
          brands.every((b) => b.brandId != _selectedBrandId)) {
        _selectedBrandId = null;
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setBrandFilter(int? brandId) {
    _selectedBrandId = brandId;
    notifyListeners();
  }

  List<BrandSalesStat> get filteredBrandStats {
    if (_summary == null) return [];
    if (_selectedBrandId == null) return _summary!.topBrands;

    return _summary!.topBrands
        .where((brand) => brand.brandId == _selectedBrandId)
        .toList();
  }
}

