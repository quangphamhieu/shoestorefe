import 'package:flutter/material.dart';
import '../../../core/network/token_handler.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/entities/order_detail.dart';
import '../../../domain/usecases/order/get_all_orders_usecase.dart';
import '../../../domain/usecases/order/create_order_usecase.dart';
import '../../../domain/usecases/order/update_order_status_usecase.dart';
import '../../../domain/usecases/order/update_order_detail_usecase.dart';
import '../../../domain/usecases/order/delete_order_detail_usecase.dart';

class StaffOrderProvider extends ChangeNotifier {
  final GetAllOrdersUseCase getAllUseCase;
  final CreateOrderUseCase createUseCase;
  final UpdateOrderStatusUseCase updateStatusUseCase;
  final UpdateOrderDetailUseCase updateDetailUseCase;
  final DeleteOrderDetailUseCase deleteDetailUseCase;

  StaffOrderProvider({
    required this.getAllUseCase,
    required this.createUseCase,
    required this.updateStatusUseCase,
    required this.updateDetailUseCase,
    required this.deleteDetailUseCase,
  });

  List<Order> _allOrders = [];
  List<Order> get allOrders => _allOrders;

  List<Order> get orders {
    final userId = TokenHandler().getUserId();
    if (userId == null) return [];
    final userIdInt = int.tryParse(userId);
    if (userIdInt == null) return [];
    
    return _allOrders.where((order) => order.createdBy == userIdInt).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isUpdatingStatus = false;
  bool get isUpdatingStatus => _isUpdatingStatus;

  bool _isDetailMutating = false;
  bool get isDetailMutating => _isDetailMutating;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  String _search = '';
  String get search => _search;

  final Set<int> _statusFilters = {};
  Set<int> get statusFilters => _statusFilters;

  int? _selectedOrderId;
  int? get selectedOrderId => _selectedOrderId;

  Order? get selectedOrder {
    if (_selectedOrderId == null) return null;
    try {
      return orders.firstWhere((order) => order.id == _selectedOrderId);
    } catch (_) {
      return null;
    }
  }

  Set<int> get selectedOrderIds {
    if (_selectedOrderId == null) return {};
    return {_selectedOrderId!};
  }

  List<Order> get filteredOrders {
    Iterable<Order> result = orders;

    if (_search.isNotEmpty) {
      final query = _search.toLowerCase();
      result = result.where((order) {
        final customer =
            (order.customerName ?? 'Khách #${order.customerId}').toLowerCase();
        final orderNumber = order.orderNumber.toLowerCase();
        final customerId = order.customerId.toString();

        return customer.contains(query) ||
            orderNumber.contains(query) ||
            customerId.contains(query);
      });
    }

    if (_statusFilters.isNotEmpty) {
      result = result.where((order) => _statusFilters.contains(order.statusId));
    }

    return result.toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await getAllUseCase.call();
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _allOrders = data;
    } catch (_) {
      _allOrders = [];
    }
    if (_selectedOrderId != null &&
        !orders.any((order) => order.id == _selectedOrderId)) {
      _selectedOrderId = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void toggleStatusFilter(int statusId) {
    if (_statusFilters.contains(statusId)) {
      _statusFilters.remove(statusId);
    } else {
      _statusFilters.add(statusId);
    }
    notifyListeners();
  }

  void clearFilters() {
    _statusFilters.clear();
    _search = '';
    notifyListeners();
  }

  bool isSelected(int orderId) => _selectedOrderId == orderId;

  void selectOrder(int? orderId) {
    _selectedOrderId = orderId;
    notifyListeners();
  }

  void clearSelection() {
    _selectedOrderId = null;
    notifyListeners();
  }

  Future<bool> createOrder({
    required int customerId,
    required int paymentMethod,
    int? storeId,
    required List<Map<String, dynamic>> details,
  }) async {
    _isCreating = true;
    notifyListeners();

    try {
      final created = await createUseCase.call(
        customerId: customerId,
        orderType: 1, // Offline
        paymentMethod: paymentMethod,
        storeId: storeId,
        details: details,
      );

      _isCreating = false;
      await loadAll();
      notifyListeners();
      return true;
    } catch (e) {
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSelectedOrdersStatus(int statusId) async {
    if (_selectedOrderId == null) return false;

    _isUpdatingStatus = true;
    notifyListeners();

    final success = await updateStatusUseCase.call(
      orderId: _selectedOrderId!,
      statusId: statusId,
    );

    _isUpdatingStatus = false;
    if (success) {
      await loadAll();
      _selectedOrderId = null;
    }
    notifyListeners();
    return success;
  }

  Future<bool> updateOrderDetailQuantity({
    required int orderDetailId,
    required int quantity,
  }) async {
    _isDetailMutating = true;
    notifyListeners();

    final success = await updateDetailUseCase.call(
      orderDetailId: orderDetailId,
      quantity: quantity,
    );

    if (success) {
      _applyDetailUpdate(detailId: orderDetailId, quantity: quantity);
    }

    _isDetailMutating = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteOrderDetail(int orderDetailId) async {
    _isDetailMutating = true;
    notifyListeners();

    final success = await deleteDetailUseCase.call(orderDetailId);

    if (success) {
      _removeDetailFromOrder(orderDetailId);
    }

    _isDetailMutating = false;
    notifyListeners();
    return success;
  }

  void _applyDetailUpdate({required int detailId, required int quantity}) {
    final orderId = _selectedOrderId;
    if (orderId == null) return;

    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final order = _allOrders[index];
    final updatedDetails =
        order.details
            .map(
              (detail) =>
                  detail.id == detailId
                      ? OrderDetail(
                        id: detail.id,
                        productId: detail.productId,
                        productName: detail.productName,
                        quantity: quantity,
                        unitPrice: detail.unitPrice,
                      )
                      : detail,
            )
            .toList();

    final newTotal = updatedDetails.fold<double>(
      0,
      (sum, detail) => sum + detail.unitPrice * detail.quantity,
    );

    _allOrders[index] = Order(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      createdBy: order.createdBy,
      creatorName: order.creatorName,
      storeId: order.storeId,
      storeName: order.storeName,
      statusId: order.statusId,
      totalAmount: newTotal,
      orderType: order.orderType,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      details: updatedDetails,
    );
  }

  void _removeDetailFromOrder(int detailId) {
    final orderId = _selectedOrderId;
    if (orderId == null) return;

    final index = _allOrders.indexWhere((order) => order.id == orderId);
    if (index == -1) return;

    final order = _allOrders[index];
    final updatedDetails =
        order.details.where((detail) => detail.id != detailId).toList();

    final newTotal = updatedDetails.fold<double>(
      0,
      (sum, detail) => sum + detail.unitPrice * detail.quantity,
    );

    _allOrders[index] = Order(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      createdBy: order.createdBy,
      creatorName: order.creatorName,
      storeId: order.storeId,
      storeName: order.storeName,
      statusId: order.statusId,
      totalAmount: newTotal,
      orderType: order.orderType,
      paymentMethod: order.paymentMethod,
      createdAt: order.createdAt,
      updatedAt: DateTime.now(),
      details: updatedDetails,
    );
  }
}

