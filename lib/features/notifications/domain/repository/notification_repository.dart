import 'package:job_finder/core/helper/typedef.dart';

abstract class NotificationRepository {
  ResultFuture<DataMap> getNotifications();
  ResultFuture<DataMap> markAsRead(String id);
}
