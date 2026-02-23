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
      _logger.w(
        "User not auth with Firebase. Attempting re-auth with stored token...",
      );
      try {
        final storage = TokenStorageImpl(const FlutterSecureStorage());
        final storedToken = await storage.readFirebaseToken();
        if (storedToken != null && storedToken.isNotEmpty) {
          await FirebaseAuth.instance.signInWithCustomToken(storedToken);
          user = FirebaseAuth.instance.currentUser;
          _logger.i("Re-auth successful. UID: ${user?.uid}");
        } else {
          _logger.e("No stored Firebase token found. Cannot re-auth.");
        }
      } catch (e) {
        _logger.e("Failed to re-authenticate with stored token: $e");
      }
    }

    _logger.i(
      "Attempting to send message. Auth UID: ${user?.uid}, Sender ID: ${message.senderId}",
    );

    if (user == null) {
      _logger.e(
        "User is still not authenticated with Firebase. This will cause Permission Denied.",
      );
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
    _logger.i("Listening to messages at: messages/$conversationId/messages");

    // Yield an empty list immediately so the UI stops showing a loading spinner
    // while we check for authentication and wait for the database connection.
    yield [];

    // Ensure we are authenticated
    if (FirebaseAuth.instance.currentUser == null) {
      _logger.w("No Firebase user. Attempting re-auth...");
      await _tryReAuth();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _logger.e("Auth failed. Stream cannot start.");
      return;
    }

    _logger.i("Starting Realtime DB listener for UID: ${user.uid}");

    yield* _getMessagesRef(conversationId).onValue
    // .timeout(
    //   const Duration(seconds: 30),
    //   onTimeout: (sink) {
    //     _logger.e(
    //       "Stream timed out for $conversationId. Database connection issue after 30s.",
    //     );
    //     sink.addError("Timeout: Could not connect to Firebase");
    //   },
    // )
    .map((event) {
      _logger.i("Data event received for $conversationId");
      final snapshotValue = event.snapshot.value;

      if (!event.snapshot.exists) {
        _logger.i(
          "Path 'messages/$conversationId/messages' does not exist in Firebase.",
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

  Future<void> _tryReAuth() async {
    try {
      final storage = TokenStorageImpl(const FlutterSecureStorage());
      final storedToken = await storage.readFirebaseToken();

      if (storedToken == null || storedToken.isEmpty) {
        _logger.w("Re-auth: No stored Firebase token found in storage.");
        return;
      }

      _logger.i(
        "Re-auth: Stored token found (len: ${storedToken.length}). Attempting sign-in...",
      );
      final userCredential = await FirebaseAuth.instance.signInWithCustomToken(
        storedToken,
      );
      _logger.i("✅ Re-auth successful. UID: ${userCredential.user?.uid}");
    } catch (e) {
      _logger.e("❌ Re-auth failed: $e");
    }
  }
}
