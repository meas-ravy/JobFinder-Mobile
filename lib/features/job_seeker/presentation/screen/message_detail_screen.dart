import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/services/firebase_chat_service.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_provider.dart';
import 'package:job_finder/core/services/agora_service.dart';
import 'package:job_finder/shared/screen/agora_call_screen.dart';
import 'package:intl/intl.dart';

class JobSeekerChatDetailScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String name;
  final String? avatar;
  final String? participantId;

  const JobSeekerChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.name,
    this.avatar,
    this.participantId,
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

  // Zego handles call invitation automatically via ZegoSendCallInvitationButton

  void _startAgoraCall({
    required BuildContext context,
    required bool isVideoCall,
    required String displayName,
    required String? displayAvatar,
  }) {
    if (widget.participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start call: participant not set')),
      );
      return;
    }
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start call: not logged in')),
      );
      return;
    }

    // Navigate immediately so user gets instant feedback
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AgoraCallScreen(
          conversationId: widget.conversationId,
          callerName: '', // Backend handles lookup
          callerAvatar: null,
          calleeId: widget.participantId!,
          calleeName: displayName,
          calleeAvatar: displayAvatar,
          isVideoCall: isVideoCall,
          isIncoming: false,
        ),
      ),
    );

    // Signal receiver via Firebase (in background)
    AgoraService.instance.sendCallInvitation(
      conversationId: widget.conversationId,
      callerId: currentUserId,
      calleeId: widget.participantId!,
      isVideoCall: isVideoCall,
      callerRole: 'Job_finder',
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
            (c is Map ? (c['id'] ?? c['_id']) : (c as dynamic).id) ==
            widget.conversationId,
        orElse: () => null,
      );
      if (convData != null) {
        conversation = convData is Map
            ? ConversationListModel.fromJson(DataMap.from(convData))
            : convData as ConversationListModel;
      }
    } catch (_) {}

    final displayName = conversation?.otherParticipant.name ?? widget.name;
    final displayAvatar =
        conversation?.otherParticipant.avatar ?? widget.avatar;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: displayAvatar != null
                      ? NetworkImage(displayAvatar)
                      : null,
                  child: displayAvatar == null
                      ? Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Active now",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.green.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.participantId != null) ...[
            _CircularAction(
              icon: Icons.call_rounded,
              onTap: () => _startAgoraCall(
                context: context,
                isVideoCall: false,
                displayName: displayName,
                displayAvatar: displayAvatar,
              ),
            ),
            _CircularAction(
              icon: Icons.videocam_rounded,
              onTap: () => _startAgoraCall(
                context: context,
                isVideoCall: true,
                displayName: displayName,
                displayAvatar: displayAvatar,
              ),
            ),
          ],
          const SizedBox(width: 12),
        ],
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

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: .3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No messages yet",
                          style: GoogleFonts.outfit(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final message = displayMessages[index];
                    final isMe = message.senderId == currentUserId;

                    // Date grouping logic
                    bool showDateHeader = false;
                    if (index == displayMessages.length - 1) {
                      showDateHeader = true;
                    } else {
                      final nextMessage = displayMessages[index + 1];
                      if (!_isSameDay(
                        message.timestamp,
                        nextMessage.timestamp,
                      )) {
                        showDateHeader = true;
                      }
                    }

                    Widget content;
                    if (message.type == 'job_card') {
                      content = _JobPreviewCard(message: message);
                    } else {
                      content = _MessageBubble(message: message, isMe: isMe);
                    }

                    if (showDateHeader) {
                      return Column(
                        children: [
                          _DateHeader(date: _getGroupDate(message.timestamp)),
                          content,
                        ],
                      );
                    }
                    return content;
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
        12,
        16,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {},
                child: Icon(
                  Icons.add_rounded,
                  color: colorScheme.primary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Write your message...",
                  hintStyle: GoogleFonts.outfit(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sendMessage,
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(dynamic ts1, dynamic ts2) {
    if (ts1 == null || ts2 == null) return false;
    DateTime d1, d2;
    try {
      if (ts1 is int) {
        d1 = DateTime.fromMillisecondsSinceEpoch(ts1);
      } else {
        d1 = DateTime.parse(ts1.toString());
      }

      if (ts2 is int) {
        d2 = DateTime.fromMillisecondsSinceEpoch(ts2);
      } else {
        d2 = DateTime.parse(ts2.toString());
      }
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (_) {
      return false;
    }
  }

  String _getGroupDate(dynamic timestamp) {
    if (timestamp == null) return "";
    try {
      DateTime date;
      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        date = DateTime.parse(timestamp.toString());
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final aDate = DateTime(date.year, date.month, date.day);

      if (aDate == today) return "Today";
      if (aDate == yesterday) return "Yesterday";
      return DateFormat('EEEE, MMMM d').format(date);
    } catch (_) {
      return "";
    }
  }
}

class _CircularAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircularAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon, size: 20),
          color: colorScheme.onSurface,
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              date,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
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
        : (isDark
              ? colorScheme.surfaceContainerHighest
              : const Color(0xFFF2F2F7));

    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF1C1C1E));

    final timeColor = isMe
        ? Colors.white.withValues(alpha: 0.7)
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 2,
          bottom: 2,
          left: isMe ? 64 : 0,
          right: isMe ? 0 : 64,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isMe ? null : bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          boxShadow: [
            if (isMe)
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.content,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: textColor,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Spacer(),
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: timeColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return "Sending...";
    try {
      DateTime date;
      if (timestamp is int) {
        date = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        date = DateTime.parse(timestamp.toString());
      }
      return DateFormat('h:mm a').format(date);
    } catch (_) {
      return "";
    }
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
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
                child:
                    job['logoUrl'] != null &&
                        job['logoUrl'].toString().isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          job['logoUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.business, color: colorScheme.primary),
                        ),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['company'] ?? 'Company Name',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                job['location'] ?? 'Location',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Salary
          Center(
            child: Text(
              job['salary'] ?? 'Unspecified Salary',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.primaryLight,
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// Tags
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (job['jobType'] != null) _buildTag(context, job['jobType']),
              if (job['workplace'] != null)
                _buildTag(context, job['workplace']),
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
