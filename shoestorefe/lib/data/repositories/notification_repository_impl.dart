import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;

  NotificationRepositoryImpl(this.remote);

  @override
  Future<List<Notification>> getAll() async {
    return await remote.getAll();
  }

  @override
  Future<Notification?> getById(int id) async {
    return await remote.getById(id);
  }

  @override
  Future<bool> delete(int id) async {
    return await remote.delete(id);
  }
}
