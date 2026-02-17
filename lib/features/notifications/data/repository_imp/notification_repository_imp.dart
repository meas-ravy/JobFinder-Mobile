import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/notifications/data/server/notification_server.dart';
import 'package:job_finder/features/notifications/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationServer _server;

  NotificationRepositoryImpl(this._server);

  @override
  ResultFuture<DataMap> getNotifications() {
    return _server.getNotifications();
  }

  @override
  ResultFuture<DataMap> markAsRead(String id) {
    return _server.markAsRead(id);
  }
}
