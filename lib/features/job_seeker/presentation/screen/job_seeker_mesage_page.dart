import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_provider.dart';

class JobSeekerMessagePage extends ConsumerStatefulWidget {
  const JobSeekerMessagePage({super.key});

  @override
  ConsumerState<JobSeekerMessagePage> createState() =>
      _JobSeekerMessagePageState();
}

class _JobSeekerMessagePageState extends ConsumerState<JobSeekerMessagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(jobSeekerChatControllerProvider.notifier).getConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSeekerChatControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final conversations = state.conversations
        .map((e) => ConversationListModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Messages",
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search messages...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                fillColor: colorScheme.surfaceContainerHighest,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(jobSeekerChatControllerProvider.notifier)
                    .getConversations();
              },
              child: state.isLoading && conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : conversations.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : ListView.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 80),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return _ConversationTile(conversation: conversation);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No messages yet",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When you contact recruiters,\nyour conversations will appear here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationListModel conversation;

  const _ConversationTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () {
        context.push(
          '${AppPath.jobSeekerChatDetail}/${conversation.id}',
          extra: {
            'name': conversation.otherParticipant.name,
            'avatar': conversation.otherParticipant.avatar,
          },
        );
      },
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: colorScheme.surfaceContainerHighest,
        backgroundImage: conversation.otherParticipant.avatar != null
            ? NetworkImage(conversation.otherParticipant.avatar!)
            : null,
        child: conversation.otherParticipant.avatar == null
            ? Text(
                conversation.otherParticipant.name[0],
                style: TextStyle(color: colorScheme.primary),
              )
            : null,
      ),
      title: Text(
        conversation.otherParticipant.name,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        conversation.lastMessageContent ?? "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: conversation.unreadCount > 0
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          fontWeight: conversation.unreadCount > 0
              ? FontWeight.w600
              : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTimestamp(conversation.lastMessageTimestamp),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                conversation.unreadCount.toString(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return "";
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      if (now.difference(dateTime).inDays == 0) {
        return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
      } else if (now.difference(dateTime).inDays < 7) {
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dateTime.weekday - 1];
      } else {
        return "${dateTime.day}/${dateTime.month}";
      }
    } catch (e) {
      return "";
    }
  }
}
