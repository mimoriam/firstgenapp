import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

// FIX: Converted to StatefulWidget to handle refresh.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // FIX: Added keys to force child widgets to rebuild on refresh.
  Key _recentMatchesKey = UniqueKey();
  Key _conversationsKey = UniqueKey();

  Future<void> _handleRefresh() async {
    // This will cause the children with these keys to be rebuilt, re-triggering their futures/streams.
    setState(() {
      _recentMatchesKey = UniqueKey();
      _conversationsKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Talk Time!', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Catch up, connect, and keep the story going.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              IconlyLight.search,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
      // FIX: Added RefreshIndicator to allow pull-to-refresh.
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            _buildSectionHeader('Recent match', textTheme),
            const SizedBox(height: 12),
            RecentMatchesList(key: _recentMatchesKey),
            const SizedBox(height: 20),
            _buildSectionHeader('Messages', textTheme),
            const SizedBox(height: 12),
            ConversationsList(key: _conversationsKey),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(title, style: textTheme.titleLarge);
  }
}

class RecentMatchesList extends StatefulWidget {
  const RecentMatchesList({super.key});

  @override
  State<RecentMatchesList> createState() => _RecentMatchesListState();
}

class _RecentMatchesListState extends State<RecentMatchesList> {
  // FIX: Changed future type to handle the full user map including UID.
  late Stream<List<Map<String, dynamic>>> _recentMatchesStream;

  @override
  void initState() {
    super.initState();
    _recentMatchesStream = _fetchRecentMatches();
  }

  Stream<List<Map<String, dynamic>>> _fetchRecentMatches() {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return firebaseService.getRecentUsers();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _recentMatchesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recent matches"));
        }
        final matches = snapshot.data!;
        return SizedBox(
          height: 75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              // FIX: Wrapped with GestureDetector to handle taps.
              return GestureDetector(
                onTap: () async {
                  final firebaseService = Provider.of<FirebaseService>(
                    context,
                    listen: false,
                  );
                  final conversation = await firebaseService
                      .getOrCreateConversation(match['uid']);
                  if (context.mounted) {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: ConversationScreen(conversation: conversation),
                      withNavBar: false,
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: NetworkImage(match['avatar']!),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        match['name']!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ConversationsList extends StatefulWidget {
  const ConversationsList({super.key});

  @override
  State<ConversationsList> createState() => _ConversationsListState();
}

class _ConversationsListState extends State<ConversationsList> {
  late Stream<List<Conversation>> _conversationsStream;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    _conversationsStream = firebaseService.getConversations();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversation>>(
      stream: _conversationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No conversations yet.'));
        }

        final conversations = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildChatItem(context, conversation),
            );
          },
        );
      },
    );
  }

  Widget _buildChatItem(BuildContext context, Conversation conversation) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ConversationScreen(conversation: conversation),
          withNavBar: false,
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(conversation.otherUser.avatarUrl),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.otherUser.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Iconsax.export_2_copy,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        conversation.lastMessage,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeAgo.format(conversation.lastMessageTimestamp),
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              _buildStatusIndicator(context, conversation, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    Conversation conversation,
    TextTheme textTheme,
  ) {
    final currentUser = Provider.of<FirebaseService>(
      context,
      listen: false,
    ).currentUser;
    if (conversation.lastMessageSenderId != currentUser?.uid &&
        conversation.unreadCount > 0) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primaryRed,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            conversation.unreadCount.toString(),
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return const Icon(
        Iconsax.tick_circle_copy,
        color: AppColors.primaryRed,
        size: 18,
      );
    }
  }
}
