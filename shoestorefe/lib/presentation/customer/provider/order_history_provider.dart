import 'package:flutter/material.dart';
import 'package:shoestorefe/domain/entities/order.dart';
import 'package:shoestorefe/domain/repositories/order_repository.dart';

class OrderHistoryProvider extends ChangeNotifier {
  final OrderRepository orderRepository;

  OrderHistoryProvider({required this.orderRepository});

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
