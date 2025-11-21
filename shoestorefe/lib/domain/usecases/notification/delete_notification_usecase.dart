import '../../repositories/notification_repository.dart';

class DeleteNotificationUseCase {
  final NotificationRepository repository;
  DeleteNotificationUseCase(this.repository);

  Future<bool> call(int id) => repository.delete(id);
}
