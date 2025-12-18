import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/usecases/order/update_order_info_usecase.dart';
import 'package:shoestorefe/domain/entities/order.dart';
import 'package:shoestorefe/domain/repositories/order_repository.dart';

class OrderHistoryProvider extends ChangeNotifier {
  final UpdateOrderInfoUseCase updateInfoUseCase;

  OrderHistoryProvider({
    required this.orderRepository,
    required this.updateInfoUseCase,
  });

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get orders for current user only
      _orders = await orderRepository.getMyOrders();

      // Sort by date (newest first)
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = e.toString();
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderInfo({
    required int orderId,
    String? note,
    String? address,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final success = await updateInfoUseCase.call(
        orderId: orderId,
        note: note,
        address: address,
      );

      if (success) {
        // Update local list
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
             final old = _orders[index];
             _orders[index] = Order(
              id: old.id,
              orderNumber: old.orderNumber,
              customerId: old.customerId,
              customerName: old.customerName,
              createdBy: old.createdBy,
              creatorName: old.creatorName,
              storeId: old.storeId,
              storeName: old.storeName,
              statusId: old.statusId,
              totalAmount: old.totalAmount,
              orderType: old.orderType,
              paymentMethod: old.paymentMethod,
              createdAt: old.createdAt,
              updatedAt: DateTime.now(),
              address: address ?? old.address,
              note: note ?? old.note,
              details: old.details,
            );
        }
        await loadOrders(); // Reload to be sure, or just rely on local update
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getStatusText(int statusId) {
    switch (statusId) {
      case 3:
        return 'Thanh toán thành công';
      case 4:
        return 'Chờ xác nhận';
      case 5:
        return 'Đã xác nhận';
      case 6:
        return 'Đã hủy';
      default:
        return 'Không rõ';
    }
  }

  Color getStatusColor(int statusId) {
    switch (statusId) {
      case 3:
        return Colors.green;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.blue;
      case 6:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
