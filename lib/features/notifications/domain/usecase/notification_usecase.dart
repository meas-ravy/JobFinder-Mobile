import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
import 'package:job_finder/features/notifications/domain/repository/notification_repository.dart';

class GetNotificationsUseCase extends UseCaseWithParams<DataMap, String?> {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  ResultFuture<DataMap> call(String? params) {
    return _repository.getNotifications(role: params);
  }
}

class MarkNotificationAsReadUseCase extends UseCaseWithParams<DataMap, String> {
  const MarkNotificationAsReadUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  ResultFuture<DataMap> call(String params) {
    return _repository.markAsRead(params);
  }
}
