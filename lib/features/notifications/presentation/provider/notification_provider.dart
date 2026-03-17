import 'package:flutter/foundation.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/notifications/data/models/notification_model.dart';
import 'package:job_finder/features/notifications/data/repository_imp/notification_repository_imp.dart';
import 'package:job_finder/features/notifications/data/server/notification_server.dart';
import 'package:job_finder/features/notifications/domain/repository/notification_repository.dart';
import 'package:job_finder/features/notifications/domain/usecase/notification_usecase.dart';
import 'package:job_finder/features/notifications/presentation/provider/notification_state.dart';

final notificationServerProvider = Provider<NotificationServer>((ref) {
  return NotificationServerImpl();
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationServerProvider));
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  return GetNotificationsUseCase(ref.watch(notificationRepositoryProvider));
});

final markAsReadUseCaseProvider = Provider<MarkNotificationAsReadUseCase>((
  ref,
) {
  return MarkNotificationAsReadUseCase(
    ref.watch(notificationRepositoryProvider),
  );
});

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
      return NotificationController(
        getNotificationsUseCase: ref.watch(getNotificationsUseCaseProvider),
        markAsReadUseCase: ref.watch(markAsReadUseCaseProvider),
        ref: ref,
      );
    });

class NotificationController extends StateNotifier<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationAsReadUseCase _markAsReadUseCase;
  final Ref _ref;

  NotificationController({
    required GetNotificationsUseCase getNotificationsUseCase,
    required MarkNotificationAsReadUseCase markAsReadUseCase,
    required Ref ref,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _ref = ref,
       super(NotificationState.initial());

  Future<void> getNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final role = await _ref.read(tokenStorageProvider).readRole();

    final result = await _getNotificationsUseCase(role);
    result.fold(
      (failure) {
        debugPrint('❌ [Notification] Fetch failed: ${failure.message}');
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        try {
          final List<dynamic> list = data['notifications'] ?? data['data'] ?? [];
          final notifications = list.map((e) {
            try {
              return NotificationModel.fromJson(e as Map<String, dynamic>);
            } catch (err) {
              debugPrint('⚠️ [Notification] Parsing individual item failed: $err');
              debugPrint('   Trace: $e');
              return null;
            }
          }).whereType<NotificationModel>().toList();
          
          final unread = notifications.where((n) => !n.isRead).length;
          debugPrint('🔔 [Notification] Parsed ${notifications.length} notifications, $unread unread');
          
          state = state.copyWith(isLoading: false, notifications: notifications);
        } catch (e) {
          debugPrint('❌ [Notification] Global parsing error: $e');
          state = state.copyWith(
            isLoading: false, 
            errorMessage: 'Failed to process notifications'
          );
        }
      },
    );
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update
    final originalNotifications = [...state.notifications];
    final updatedNotifications = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updatedNotifications);

    final result = await _markAsReadUseCase(id);
    result.fold(
      (failure) {
        // Rollback if failed
        state = state.copyWith(notifications: originalNotifications);
      },
      (data) {
        // Success, keep the local state
      },
    );
  }
}
