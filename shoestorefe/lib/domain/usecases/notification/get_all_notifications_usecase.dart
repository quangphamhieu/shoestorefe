import '../../entities/notification.dart';
import '../../repositories/notification_repository.dart';

class GetAllNotificationsUseCase {
  final NotificationRepository repository;
  GetAllNotificationsUseCase(this.repository);

  Future<List<Notification>> call() => repository.getAll();
}
