import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';

class RecruiterMessagePage extends ConsumerStatefulWidget {
  const RecruiterMessagePage({super.key});

  @override
  ConsumerState<RecruiterMessagePage> createState() =>
      _RecruiterMessagePageState();
}

class _RecruiterMessagePageState extends ConsumerState<RecruiterMessagePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        ref.read(recruiterControllerProvider.notifier).getConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recruiterControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final conversations = state.conversations.map((e) {
      final mapData = (e is Map)
          ? Map<String, dynamic>.from(e)
          : <String, dynamic>{};
      return ConversationListModel.fromJson(mapData);
    }).toList();

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
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search messages...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                fillColor: colorScheme.surfaceContainerHighest,
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(recruiterControllerProvider.notifier)
                    .getConversations();
              },
              child: state.isLoading && conversations.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                  : conversations.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : ListView.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
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
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "When you start talking with candidates,\nyour conversations will appear here.",
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
          '${AppPath.chatDetail}/${conversation.id}',
          extra: {
            'candidateName': conversation.otherParticipant.name,
            'candidateAvatar': conversation.otherParticipant.avatar,
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
        style: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        conversation.lastMessageContent ?? "No messages yet",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 13,
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
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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
