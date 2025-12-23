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

  Future<void> loadDashboard({int? storeId, int? brandId, int? months}) async {
    if (storeId != null) _selectedStoreId = storeId;
    // Allow clearing filter if explicitly passed as null? simpler logic:
    // If param passed, update state. If not, keep current state.
    // Actually user might want to clear brand.
    // Let's assume the UI calls explicit values.
    
    // For specific "setter" actions, we use setBrand/setStore methods.
    // loadDashboard can just trigger the fetch with current state.
    
    if (months != null && months > 0) {
      _months = months;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _summary = await getDashboardOverviewUseCase.call(
        storeId: _selectedStoreId,
        brandId: _selectedBrandId,
        months: _months,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setStoreFilter(int? storeId) {
    _selectedStoreId = storeId;
    loadDashboard();
  }

  void setBrandFilter(int? brandId) {
    _selectedBrandId = brandId;
    loadDashboard();
  }
  
  void setMonthFilter(int months) {
    _months = months;
    loadDashboard();
  }

  // With server-side filtering, 'topBrands' returned are already filtered (or just 1 brand row).
  // So we just return the list as is.
  List<BrandSalesStat> get filteredBrandStats {
    if (_summary == null) return [];
    return _summary!.topBrands;
  }
}

