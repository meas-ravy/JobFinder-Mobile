import 'package:job_finder/core/helper/typedef.dart';

abstract class NotificationRepository {
  ResultFuture<DataMap> getNotifications({String? role});
  ResultFuture<DataMap> markAsRead(String id);
}
