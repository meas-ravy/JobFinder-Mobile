import 'package:job_finder/features/notifications/data/models/notification_model.dart';

class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final String? errorMessage;

  NotificationState({
    required this.notifications,
    required this.isLoading,
    this.errorMessage,
  });

  factory NotificationState.initial() {
    return NotificationState(notifications: [], isLoading: false);
  }

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
