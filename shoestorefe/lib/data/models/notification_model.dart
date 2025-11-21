import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required super.id,
    super.code,
    required super.title,
    required super.message,
    super.type,
    required super.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      code: json['code'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
