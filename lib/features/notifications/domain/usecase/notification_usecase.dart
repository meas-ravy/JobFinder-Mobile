import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
import 'package:job_finder/features/notifications/domain/repository/notification_repository.dart';

class GetNotificationsUseCase extends UseCaseWithOutParams<DataMap> {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  ResultFuture<DataMap> call() {
    return _repository.getNotifications();
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
