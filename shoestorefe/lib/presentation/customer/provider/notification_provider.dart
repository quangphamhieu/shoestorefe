import 'package:flutter/material.dart';
import '../../../domain/entities/notification.dart' as entity;
import '../../../domain/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository notificationRepository;

  NotificationProvider({required this.notificationRepository});

  List<entity.Notification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<entity.Notification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount =>
      _notifications.length; // Simplified: all notifications are unread

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await notificationRepository.getAll();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int id) async {
    try {
      final success = await notificationRepository.delete(id);
      if (success) {
        _notifications.removeWhere((n) => n.id == id);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
