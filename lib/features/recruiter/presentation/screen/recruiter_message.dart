import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class RecruiterMessagePage extends ConsumerStatefulWidget {
  const RecruiterMessagePage({super.key});

  @override
  ConsumerState<RecruiterMessagePage> createState() =>
      _RecruiterMessagePageState();
}

class _RecruiterMessagePageState extends ConsumerState<RecruiterMessagePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    Future.microtask(() {
      if (mounted) {
        ref
            .read(recruiterConversationsControllerProvider.notifier)
            .getConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recruiterConversationsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final conversations = state.conversations.map((e) {
      final mapData = (e is Map)
          ? Map<String, dynamic>.from(e)
          : <String, dynamic>{};
      return ConversationListModel.fromJson(mapData);
    }).toList();

    final filteredConversations = _searchQuery.isEmpty
        ? conversations
        : conversations
              .where(
                (c) => c.otherParticipant.name.toLowerCase().contains(
                  _searchQuery,
                ),
              )
              .toList();

    // Isolate loading state
    final isConversationsLoading =
        (state.isLoading || state.isInitial) && conversations.isEmpty;

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
              controller: _searchController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: "Search messages...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppSvgIcon(
                    assetName: AppIcon.search,
                    color: colorScheme.onSurfaceVariant,
                  ),
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
                    .read(recruiterConversationsControllerProvider.notifier)
                    .getConversations();
              },
              child: _buildContent(
                context: context,
                colorScheme: colorScheme,
                isLoading: isConversationsLoading,
                conversations: conversations,
                filteredConversations: filteredConversations,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required ColorScheme colorScheme,
    required bool isLoading,
    required List<ConversationListModel> conversations,
    required List<ConversationListModel> filteredConversations,
  }) {
    // Always use scrollable physics so RefreshIndicator gesture fires in ALL states
    const physics = AlwaysScrollableScrollPhysics();

    if (isLoading) {
      return ListView.separated(
        physics: physics,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const _MessageShimmer(),
      );
    }

    if (filteredConversations.isEmpty) {
      return SingleChildScrollView(
        physics: physics,
        child: SizedBox(
          height: 400,
          child: conversations.isEmpty
              ? _buildEmptyState(colorScheme)
              : Center(
                  child: Text(
                    "No messages match your search.",
                    style: GoogleFonts.outfit(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
        ),
      );
    }

    return ListView.separated(
      physics: physics,
      itemCount: filteredConversations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final conversation = filteredConversations[index];
        return _ConversationTile(conversation: conversation);
      },
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
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
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
            'participantId': conversation.otherParticipant.id,
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

class _MessageShimmer extends StatelessWidget {
  const _MessageShimmer();

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: ShimmerCircle(radius: 28),
      title: Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: ShimmerLoading(width: 120, height: 16),
      ),
      subtitle: ShimmerLoading(width: double.infinity, height: 12),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ShimmerLoading(width: 40, height: 12),
          SizedBox(height: 8),
          ShimmerCircle(radius: 8),
        ],
      ),
    );
  }
}
