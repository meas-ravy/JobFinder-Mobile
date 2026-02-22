import 'package:firebase_database/firebase_database.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';
import 'package:logger/logger.dart';

class FirebaseChatService {
  FirebaseChatService._();
  static final FirebaseChatService instance = FirebaseChatService._();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final _logger = Logger();

  DatabaseReference _getMessagesRef(String conversationId) {
    return _db.ref("conversations/$conversationId/messages");
  }

  Future<void> sendMessage(
    String conversationId,
    ChatMessageModel message,
  ) async {
    try {
      final ref = _getMessagesRef(conversationId);
      await ref.push().set(message.toMap());
      _logger.i("Message sent to conversation: $conversationId");
    } catch (e) {
      _logger.e("Failed to send message: $e");
      rethrow;
    }
  }

  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    _logger.i(
      "Listening to messages at: conversations/$conversationId/messages",
    );
    return _getMessagesRef(conversationId).onValue.map((event) {
      final snapshotValue = event.snapshot.value;

      if (!event.snapshot.exists) {
        _logger.i(
          "Path 'conversations/$conversationId/messages' does not exist in Firebase.",
        );
        return [];
      }

      if (snapshotValue == null) {
        _logger.i("Snapshot value is null for $conversationId");
        return [];
      }

      final List<ChatMessageModel> messages = [];

      try {
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
          _logger.i("Firebase returned a List for messages in $conversationId");
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
      } catch (e) {
        _logger.e("Error parsing messages list: $e");
      }

      // Sort messages by timestamp
      messages.sort((a, b) {
        final aTime = a.timestamp is int ? a.timestamp as int : 0;
        final bTime = b.timestamp is int ? b.timestamp as int : 0;
        return aTime.compareTo(bTime);
      });

      _logger.i(
        "Successfully parsed ${messages.length} messages for $conversationId",
      );
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
