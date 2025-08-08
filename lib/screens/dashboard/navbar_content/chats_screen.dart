import 'package:firstgenapp/screens/conversation/conversation_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // Mock data based on the screenshot
  final List<Map<String, String>> _recentMatches = [
    {
      'name': 'Ariana',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
    },
    {
      'name': 'Jenny',
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {'name': 'Jame', 'avatar': 'https://randomuser.me/api/portraits/men/1.jpg'},
    {
      'name': 'Nalli',
      'avatar': 'https://randomuser.me/api/portraits/women/3.jpg',
    },
    {'name': 'Ken', 'avatar': 'https://randomuser.me/api/portraits/men/2.jpg'},
    {'name': 'Jam', 'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'},
  ];

  final List<Map<String, dynamic>> _todayMessages = [
    {
      'name': 'Ariana',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
      'lastMessage': 'Nice to meet you, darling. How has your day been so far?',
      'time': '7:09 pm',
      'status': 'read',
      'unreadCount': 0,
    },
    {
      'name': 'Jame',
      'avatar': 'https://randomuser.me/api/portraits/men/1.jpg',
      'lastMessage': 'Hey bro, do you want to catch up later this week?',
      'time': '5:35 pm',
      'status': 'unread',
      'unreadCount': 1,
    },
  ];

  final List<Map<String, dynamic>> _yesterdayMessages = [
    {
      'name': 'Kensington Montgomery III',
      'avatar': 'https://randomuser.me/api/portraits/men/2.jpg',
      'lastMessage': 'I absolutely agree with your opinion on that matter.',
      'time': '10:09 pm',
      'status': 'read',
      'unreadCount': 0,
    },
    {
      'name': 'Ken',
      'avatar': 'https://randomuser.me/api/portraits/women/4.jpg',
      'lastMessage': 'Your voice is so attractive!',
      'time': '8:00 pm',
      'status': 'unread',
      'unreadCount': 8,
    },
    {
      'name': 'Jenny',
      'avatar': 'https://randomuser.me/api/portraits/women/2.jpg',
      'lastMessage':
          'Yesterday I went to the most amazing concert, you would have loved it!',
      'time': '8:00 pm',
      'status': 'unread',
      'unreadCount': 8,
    },
    {
      'name': 'Jan',
      'avatar': 'https://randomuser.me/api/portraits/women/5.jpg',
      'lastMessage': 'Unfortunately I\'m not at the office today.',
      'time': '8:00 pm',
      'status': 'read',
      'unreadCount': 0,
    },
  ];

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          // UPDATED: Reduced spacing
          const SizedBox(height: 16),
          _buildSectionHeader('Recent match', textTheme),
          const SizedBox(height: 12),
          _buildRecentMatchesList(),
          // UPDATED: Reduced spacing
          const SizedBox(height: 20),
          _buildSectionHeader('Today Message', textTheme),
          const SizedBox(height: 12),
          ..._todayMessages.map(
            (msg) => Padding(
              // UPDATED: Reduced padding
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildChatItem(msg),
            ),
          ),
          _buildSectionHeader('Yesterday', textTheme),
          const SizedBox(height: 12),
          ..._yesterdayMessages.map(
            (msg) => Padding(
              // UPDATED: Reduced padding
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildChatItem(msg),
            ),
          ),
        ],
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
    return SizedBox(
      // UPDATED: Reduced height for compactness
      height: 75,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _recentMatches.length,
        itemBuilder: (context, index) {
          final match = _recentMatches[index];
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
  }

  Widget _buildChatItem(Map<String, dynamic> message) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ConversationScreen(),
            withNavBar: false,
          );
        }
      },
      child: Row(
        children: [
          CircleAvatar(
            // UPDATED: Reduced size
            radius: 26,
            backgroundImage: NetworkImage(message['avatar']),
          ),
          // UPDATED: Reduced spacing
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['name'],
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
                        message['lastMessage'],
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
                message['time'],
                // UPDATED: Inherited from theme
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              _buildStatusIndicator(
                message['status'],
                message['unreadCount'],
                textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
    String status,
    int unreadCount,
    TextTheme textTheme,
  ) {
    if (status == 'unread' && unreadCount > 0) {
      return Container(
        width: 20,
        height: 20,
        decoration: const BoxDecoration(
          color: AppColors.primaryRed,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            unreadCount.toString(),
            // UPDATED: Inherited from theme
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      return const Icon(Iconsax.tick_circle_copy, color: AppColors.primaryRed, size: 18);
    }
  }
}
