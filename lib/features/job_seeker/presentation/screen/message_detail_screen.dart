import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/services/firebase_chat_service.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:job_finder/features/chat/presentation/screen/call_screen.dart';

class JobSeekerChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String name;
  final String? avatar;

  const JobSeekerChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.name,
    this.avatar,
  });

  @override
  ConsumerState<JobSeekerChatDetailScreen> createState() =>
      _JobSeekerChatDetailScreenState();
}

class _JobSeekerChatDetailScreenState
    extends ConsumerState<JobSeekerChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Stream<List<ChatMessageModel>> _messagesStream;

  @override
  void initState() {
    super.initState();
    _messagesStream = FirebaseChatService.instance.getMessagesStream(
      widget.conversationId,
    );

    // Initial fetch of conversations if empty, to recover name/avatar from notification navigation
    Future.microtask(() {
      final state = ref.read(jobSeekerChatControllerProvider);
      if (state.conversations.isEmpty) {
        ref.read(jobSeekerChatControllerProvider.notifier).getConversations();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User profile not loaded")),
      );
      return;
    }

    final newMessage = ChatMessageModel(
      content: content,
      senderId: currentUserId,
      senderType: "User",
    );

    _messageController.clear();

    try {
      await FirebaseChatService.instance.sendMessage(
        widget.conversationId,
        newMessage,
      );

      ref.read(jobSeekerChatControllerProvider.notifier).updateConversation(
        widget.conversationId,
        {"lastMessageContent": content},
      );

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send message: $e")));
    }
  }

  Future<void> _startCall(bool isVideo) async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) return;

    if (isVideo) {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) return;
    }

    await ref
        .read(jobSeekerChatControllerProvider.notifier)
        .getAgoraToken(widget.conversationId);

    final state = ref.read(jobSeekerChatControllerProvider);
    if (state.agoraAppId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to get App ID")));
      return;
    }

    ref.read(jobSeekerChatControllerProvider.notifier).signalCall({
      "conversationId": widget.conversationId,
      "signalType": "START_CALL",
      "callType": isVideo ? "VIDEO" : "VOICE",
    });

    // Try to get dynamic name and avatar
    final displayName = widget.name;
    final displayAvatar = widget.avatar;

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          channelName: widget.conversationId,
          token: state.agoraToken!,
          appId: state.agoraAppId!,
          isVideoCall: isVideo,
          remoteName: displayName,
          remoteAvatar: displayAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

    // Try to find conversation in state to get name and avatar if missing (from notification)
    final chatState = ref.watch(jobSeekerChatControllerProvider);
    ConversationListModel? conversation;
    try {
      final convData = chatState.conversations.firstWhere(
        (c) =>
            (c is Map ? c['id'] : (c as dynamic).id) == widget.conversationId,
        orElse: () => null,
      );
      if (convData != null) {
        conversation = convData is Map
            ? ConversationListModel.fromJson(
                Map<String, dynamic>.from(convData),
              )
            : convData as ConversationListModel;
      }
    } catch (_) {}

    final displayName = conversation?.otherParticipant.name ?? widget.name;
    final displayAvatar =
        conversation?.otherParticipant.avatar ?? widget.avatar;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: displayAvatar != null
                    ? NetworkImage(displayAvatar)
                    : null,
                child: displayAvatar == null
                    ? Text(
                        displayName[0].toUpperCase(),
                        style: TextStyle(color: colorScheme.primary),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "Online",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.phone_outlined, color: colorScheme.onSurface),
              onPressed: () => _startCall(false),
            ),
            IconButton(
              icon: Icon(Icons.videocam_outlined, color: colorScheme.onSurface),
              onPressed: () => _startCall(true),
            ),
            IconButton(
              icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: colorScheme.error,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Connection Error",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final displayMessages = messages.reversed.toList();

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    if (message.type == 'job_card') {
                      return _JobPreviewCard(message: message);
                    }

                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: "Type a message ...",
                        hintStyle: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  Icon(Icons.attach_file, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.camera_alt_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bubbleColor = isMe
        ? colorScheme.primary
        : (isDark ? AppColor.leftMessageColorDark : const Color(0xffF2F2F2));

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                if (!isMe && !isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _formatDate(message.timestamp),
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "Sending...";
    try {
      if (timestamp is int) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        return DateFormat('HH:mm').format(date);
      } else if (timestamp is String) {
        final date = DateTime.parse(timestamp);
        return DateFormat('HH:mm').format(date);
      }
    } catch (_) {}
    return "";
  }
}

class _JobPreviewCard extends StatelessWidget {
  final ChatMessageModel message;

  const _JobPreviewCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final job = message.jobData;

    if (job == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child:
                    job['logoUrl'] != null &&
                        job['logoUrl'].toString().isNotEmpty
                    ? Image.network(
                        job['logoUrl'].toString(),
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.business, color: colorScheme.primary),
                      )
                    : Icon(Icons.business, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? 'Job Title',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['company'] ?? 'Company Name',
                      style: GoogleFonts.inter(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  job['location'] ?? 'Location',
                  style: GoogleFonts.inter(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            job['salary'] ?? 'Unspecified Salary',
            style: GoogleFonts.inter(
              color: AppColor.primaryLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job['jobType'] != null)
                _buildTag(context, job['jobType'].toString()),
              if (job['workplace'] != null)
                _buildTag(context, job['workplace'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
