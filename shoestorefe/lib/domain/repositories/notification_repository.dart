import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getAll();
  Future<Notification?> getById(int id);
  Future<bool> delete(int id);
}
