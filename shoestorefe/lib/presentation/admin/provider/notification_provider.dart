import 'package:flutter/material.dart';
import '../../../domain/entities/notification.dart' as domain;
import '../../../domain/usecases/notification/get_all_notifications_usecase.dart';
import '../../../domain/usecases/notification/get_notification_by_id_usecase.dart';
import '../../../domain/usecases/notification/delete_notification_usecase.dart';

class NotificationProvider extends ChangeNotifier {
  final GetAllNotificationsUseCase getAllUseCase;
  final GetNotificationByIdUseCase getByIdUseCase;
  final DeleteNotificationUseCase deleteUseCase;

  NotificationProvider({
    required this.getAllUseCase,
    required this.getByIdUseCase,
    required this.deleteUseCase,
  });

  List<domain.Notification> _notifications = [];
  List<domain.Notification> get notifications => _notifications;

  Set<int> _readNotificationIds = {}; // IDs của notifications đã đọc
  DateTime?
  _lastReadTime; // Thời điểm user click vào notification icon lần cuối

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Số thông báo chưa đọc = tổng số - số đã đọc (hoặc notifications sau lastReadTime)
  int get unreadCount {
    if (_lastReadTime == null) {
      // Nếu chưa bao giờ click vào notification, tất cả đều là unread
      return _notifications.length;
    }
    // Đếm số notifications được tạo sau thời điểm đọc cuối cùng
    return _notifications
        .where((n) => n.createdAt.isAfter(_lastReadTime!))
        .length;
  }

  List<domain.Notification> get unreadNotifications {
    if (_lastReadTime == null) {
      return _notifications;
    }
    return _notifications
        .where((n) => n.createdAt.isAfter(_lastReadTime!))
        .toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    try {
      final all = await getAllUseCase.call();
      // Sắp xếp theo thời gian mới nhất trước
      _notifications = all..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      _notifications = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // Đánh dấu tất cả notifications là đã đọc (khi user click vào notification icon)
  void markAllAsRead() {
    _lastReadTime = DateTime.now();
    notifyListeners();
  }

  // Tăng unread count khi có API call thành công
  // Method này sẽ được gọi từ các provider khác khi có operation thành công
  void incrementUnreadCount() {
    // Không cần làm gì, vì unreadCount được tính dựa trên _lastReadTime
    // Chỉ cần reload notifications để lấy thông báo mới
    loadAll();
  }

  Future<bool> deleteNotification(int id) async {
    try {
      final result = await deleteUseCase.call(id);
      if (result) {
        _notifications.removeWhere((n) => n.id == id);
        notifyListeners();
      }
      return result;
    } catch (_) {
      return false;
    }
  }

  // Polling để tự động refresh notifications mỗi X giây
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    // Sẽ được implement nếu cần
  }
}
