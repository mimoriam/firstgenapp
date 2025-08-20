import 'dart:async';

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
  Key _recentMatchesKey = UniqueKey();

  // State for conversations and search
  List<Conversation> _allConversations = [];
  List<Conversation> _filteredConversations = [];
  StreamSubscription<List<Conversation>>? _conversationsSubscription;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false; // To toggle search bar visibility

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToConversations();
    _searchController.addListener(_filterConversations);
  }

  /// Subscribes to the conversation stream and updates the local lists.
  void _listenToConversations() {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    _conversationsSubscription = firebaseService.getConversations().listen((
      conversations,
    ) {
      if (mounted) {
        setState(() {
          _allConversations = conversations;
          _filteredConversations = conversations;
          _isLoading = false; // Set loading to false here
          _filterConversations();
        });
      }
    });
  }

  /// Filters the conversations based on the search query.
  void _filterConversations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConversations = _allConversations.where((conversation) {
        final userName = conversation.otherUser.name.toLowerCase();
        return userName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _searchController.removeListener(_filterConversations);
    _searchController.dispose();
    super.dispose();
  }

  /// Handles the pull-to-refresh action.
  Future<void> _handleRefresh() async {
    setState(() {
      _recentMatchesKey = UniqueKey();
    });
  }

  /// Builds the default AppBar.
  AppBar _buildNormalAppBar(TextTheme textTheme) {
    return AppBar(
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
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
          icon: const Icon(
            IconlyLight.search,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ],
    );
  }

  /// Builds the AppBar with the search text field.
  AppBar _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
      //   onPressed: () {
      //     setState(() {
      //       _isSearching = false;
      //       _searchController.clear();
      //     });
      //   },
      // ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search by name...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: AppColors.textSecondary),
        ),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
          icon: const Icon(
            Icons.close,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _isSearching
          ? _buildSearchAppBar()
          : _buildNormalAppBar(textTheme),
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
            _buildConversationsList(),
          ],
        ),
      ),
    );
  }

  /// Builds the list of conversations using the filtered data.
  Widget _buildConversationsList() {
    // 1. Show a loading indicator until the initial fetch is complete.
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. If a search is active and yields no results, show the "not found" message.
    if (_searchController.text.isNotEmpty && _filteredConversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No matching conversations found.'),
        ),
      );
    }

    // 3. If the initial fetch is done and there are no conversations at all, show this message.
    if (_allConversations.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No conversations yet.'),
        ),
      );
    }

    // 4. Otherwise, display the list of conversations.
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = _filteredConversations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildChatItem(context, conversation),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, TextTheme textTheme) {
    return Text(title, style: textTheme.titleLarge);
  }

  /// Builds a single chat item tile.
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

  /// Builds the unread message count or read receipt indicator.
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

/// Widget for displaying the list of recent matches.
class RecentMatchesList extends StatefulWidget {
  const RecentMatchesList({super.key});

  @override
  State<RecentMatchesList> createState() => _RecentMatchesListState();
}

class _RecentMatchesListState extends State<RecentMatchesList> {
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
