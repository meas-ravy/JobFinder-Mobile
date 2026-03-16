import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/conversation_list_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/application_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/ai_assistant_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/ai_assistant/premium_paywall.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class JobSeekerMessagePage extends ConsumerStatefulWidget {
  const JobSeekerMessagePage({super.key});

  @override
  ConsumerState<JobSeekerMessagePage> createState() =>
      _JobSeekerMessagePageState();
}

class _JobSeekerMessagePageState extends ConsumerState<JobSeekerMessagePage> {
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
        ref.read(jobSeekerChatControllerProvider.notifier).getConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobSeekerChatControllerProvider);
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            "Messages",
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 4, color: colorScheme.primary),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                insets: const EdgeInsets.symmetric(horizontal: 16),
              ),
              labelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              unselectedLabelStyle: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey[500],
              tabs: const [
                Tab(text: "Chats"),
                Tab(text: "Interview Practice"),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Chats
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search messages...",
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: AppSvgIcon(
                          assetName: AppIcon.search,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
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
            // Tab 2: Interview Practice
            const InterviewPracticeTab(),
          ],
        ),
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
    const physics = AlwaysScrollableScrollPhysics();

    if (isLoading) {
      return ListView.separated(
        physics: physics,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: 8,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => const _MessageShimmer(),
      );
    }

    if (filteredConversations.isEmpty) {
      return SingleChildScrollView(
        physics: physics,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          alignment: Alignment.center,
          child: conversations.isEmpty
              ? _buildEmptyState(colorScheme)
              : Text(
                  "No messages match your search.",
                  style: GoogleFonts.outfit(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
        ),
      );
    }

    return ListView.separated(
      physics: physics,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    return InkWell(
      onTap: () {
        context.push(
          '${AppPath.jobSeekerChatDetail}/${conversation.id}',
          extra: {
            'name': conversation.otherParticipant.name,
            'avatar': conversation.otherParticipant.avatar,
            'participantId': conversation.otherParticipant.id,
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: conversation.otherParticipant.avatar != null
                      ? NetworkImage(conversation.otherParticipant.avatar!)
                      : null,
                  child: conversation.otherParticipant.avatar == null
                      ? Text(
                          conversation.otherParticipant.name[0],
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : null,
                ),
                // Potential online indicator could go here
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation.otherParticipant.name,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        _formatTimestamp(conversation.lastMessageTimestamp),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
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
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                ],
              ),
            ),
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const ShimmerCircle(radius: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const ShimmerLoading(width: 120, height: 16),
                    const ShimmerLoading(width: 40, height: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const ShimmerLoading(width: double.infinity, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InterviewPracticeTab extends ConsumerWidget {
  const InterviewPracticeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(myApplicationsProvider);
    final isPremium = ref.watch(premiumStatusProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myApplicationsProvider);
      },
      child: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_outlined,
                        size: 80,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "Elevate Your Interview Game",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "After you apply for a job, you'll see it here. Practice with our AI to nail your real interview!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final app = applications[index];
              final job = app.job;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      if (!isPremium) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => PremiumPaywall(isDark: isDark),
                        );
                        return;
                      }
                      context.push(
                        AppPath.interviewCoach,
                        extra: {
                          'jobTitle': job?.title ?? '',
                          'jobDescription': job?.description ?? '',
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: job?.companyProfile?.logoUrl != null
                                      ? Image.network(
                                          job!.companyProfile!.logoUrl!,
                                          fit: BoxFit.contain,
                                        )
                                      : const Icon(Icons.business),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      job?.title ?? 'Job Title',
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      job?.companyProfile?.name ??
                                          'Company Name',
                                      style: GoogleFonts.outfit(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isPremium)
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock_outline,
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: (isPremium ? colorScheme.primary : Colors.grey).withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPremium ? Icons.auto_awesome : Icons.lock_person_outlined,
                                      size: 14,
                                      color: isPremium ? colorScheme.primary : Colors.grey,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isPremium ? 'Interview Preparation' : 'Premium Feature',
                                      style: GoogleFonts.outfit(
                                        color: isPremium ? colorScheme.primary : Colors.grey,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Text(
                                isPremium ? 'Practice Now' : 'Upgrade to Practice',
                                style: GoogleFonts.outfit(
                                  color: isPremium ? colorScheme.primary : Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward,
                                size: 16,
                                color: isPremium ? colorScheme.primary : Colors.amber,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
