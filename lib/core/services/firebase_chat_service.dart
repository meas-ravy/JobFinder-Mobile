import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';
import 'package:logger/logger.dart';

class FirebaseChatService {
  FirebaseChatService._();
  static final FirebaseChatService instance = FirebaseChatService._();

  final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL:
        'https://push-notification-de8ac-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
  final _logger = Logger();

  DatabaseReference _getMessagesRef(String conversationId) {
    return _db.ref("messages/$conversationId/messages");
  }

  Future<void> sendMessage(
    String conversationId,
    ChatMessageModel message,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      try {
        final storage = TokenStorageImpl(const FlutterSecureStorage());
        final storedToken = await storage.readFirebaseToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          await FirebaseAuth.instance.signInWithCustomToken(storedToken);
          user = FirebaseAuth.instance.currentUser;
        } else {
          _logger.e("No stored Firebase token found. Cannot re-auth.");
        }
      } catch (e) {
        _logger.e("Failed to re-authenticate with stored token: $e");
      }
    }

    try {
      final ref = _getMessagesRef(conversationId);
      await ref.push().set(message.toMap());
      _logger.i("Message sent successfully to path: ${ref.path}");
    } catch (e) {
      _logger.e("Failed to send message: $e");
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> getMessagesStream(
    String conversationId,
  ) async* {
    yield* _getMessagesRef(conversationId).onValue.map((event) {
      final snapshotValue = event.snapshot.value;
      final List<ChatMessageModel> messages = [];

      if (snapshotValue is Map) {
        final Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
          snapshotValue,
        );
        data.forEach((key, value) {
          if (value is Map) {
            messages.add(
              ChatMessageModel.fromMap(
                key.toString(),
                Map<dynamic, dynamic>.from(value),
              ),
            );
          }
        });
      } else if (snapshotValue is List) {
        for (int i = 0; i < snapshotValue.length; i++) {
          final value = snapshotValue[i];
          if (value is Map) {
            messages.add(
              ChatMessageModel.fromMap(
                i.toString(),
                Map<dynamic, dynamic>.from(value),
              ),
            );
          }
        }
      }

      // Sort messages by timestamp
      messages.sort((a, b) {
        final aTime = a.timestamp is int ? a.timestamp as int : 0;
        final bTime = b.timestamp is int ? b.timestamp as int : 0;
        return aTime.compareTo(bTime);
      });

      return messages;
    });
  }

  // Listener for a single new child added (can be used for notifications if needed)
  Stream<ChatMessageModel> onMessageAdded(String conversationId) {
    return _getMessagesRef(conversationId).onChildAdded.map((event) {
      final snapshotValue = event.snapshot.value;
      final Map<dynamic, dynamic> data = (snapshotValue is Map)
          ? Map<dynamic, dynamic>.from(snapshotValue)
          : {};
      return ChatMessageModel.fromMap(event.snapshot.key!, data);
    });
  }
}
