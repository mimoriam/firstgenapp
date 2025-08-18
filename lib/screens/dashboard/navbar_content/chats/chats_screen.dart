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

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late Future<List<Map<String, String>>> _recentMatchesFuture;

  @override
  void initState() {
    super.initState();
    _recentMatchesFuture = _fetchRecentMatches();
  }

  Future<List<Map<String, String>>> _fetchRecentMatches() async {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final users = await firebaseService.getRecentUsers();
    return users.map((user) {
      final data = user.data();
      return {
        'name': data['fullName'] as String? ?? 'No Name',
        'avatar':
            data['profileImageUrl'] as String? ??
            'https://picsum.photos/seed/${data['uid']}/200/200',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Talk Time!',
              // UPDATED: Inherited from theme
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Catch up, connect, and keep the story going.',
              // UPDATED: Inherited from theme
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              // Icons.search,
              IconlyLight.search,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: firebaseService.getConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No conversations yet.'));
          }

          final conversations = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              // UPDATED: Reduced spacing
              const SizedBox(height: 16),
              _buildSectionHeader('Recent match', textTheme),
              const SizedBox(height: 12),
              _buildRecentMatchesList(),
              // UPDATED: Reduced spacing
              const SizedBox(height: 20),
              _buildSectionHeader('Messages', textTheme),
              const SizedBox(height: 12),
              ...conversations.map(
                (conversation) => Padding(
                  // UPDATED: Reduced padding
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildChatItem(conversation),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(
      title,
      // UPDATED: Inherited from theme
      style: textTheme.titleLarge,
    );
  }

  Widget _buildRecentMatchesList() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _recentMatchesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No recent matches"));
        }
        final matches = snapshot.data!;
        return SizedBox(
          // UPDATED: Reduced height for compactness
          height: 75,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      // UPDATED: Reduced size
                      radius: 26,
                      backgroundImage: NetworkImage(match['avatar']!),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      match['name']!,
                      // UPDATED: Inherited from theme
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildChatItem(Conversation conversation) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ConversationScreen(conversation: conversation),
            withNavBar: false,
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            // UPDATED: Reduced size
            radius: 26,
            backgroundImage: NetworkImage(conversation.otherUser.avatarUrl),
          ),
          // UPDATED: Reduced spacing
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.otherUser.name,
                  // UPDATED: Inherited from theme
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
                      // Icons.history,
                      Iconsax.export_2_copy,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        conversation.lastMessage,
                        // UPDATED: Inherited from theme
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
          // UPDATED: Reduced spacing
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                TimeAgo.format(conversation.lastMessageTimestamp),
                // UPDATED: Inherited from theme
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              _buildStatusIndicator(conversation, textTheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Conversation conversation, TextTheme textTheme) {
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
            // UPDATED: Inherited from theme
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
