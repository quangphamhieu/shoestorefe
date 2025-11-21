import '../../entities/notification.dart';
import '../../repositories/notification_repository.dart';

class GetNotificationByIdUseCase {
  final NotificationRepository repository;
  GetNotificationByIdUseCase(this.repository);

  Future<Notification?> call(int id) => repository.getById(id);
}
