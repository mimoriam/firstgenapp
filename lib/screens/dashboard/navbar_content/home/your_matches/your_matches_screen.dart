// lib/screens/dashboard/navbar_content/home/your_matches/your_matches_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class YourMatchesScreen extends StatefulWidget {
  const YourMatchesScreen({super.key});

  @override
  State<YourMatchesScreen> createState() => _YourMatchesScreenState();
}

class _YourMatchesScreenState extends State<YourMatchesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _matches = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _getMatches();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMatches();
      }
    });
  }

  Future<void> _getMatches() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final newMatches = await firebaseService.getAllMatches(
      startAfter: _lastDocument,
      limit: 12,
    );

    if (newMatches.isEmpty) {
      setState(() {
        _hasMore = false;
        _isLoading = false;
      });
    } else {
      _lastDocument = newMatches.last;
      setState(() {
        _matches.addAll(newMatches);
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _calculateAge(Timestamp? dobTimestamp) {
    if (dobTimestamp == null) return 0;
    final dob = dobTimestamp.toDate();
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: StreamBuilder<int>(
          stream: firebaseService.getMatchesCount(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return RichText(
              text: TextSpan(
                style: textTheme.headlineSmall,
                children: [
                  const TextSpan(text: 'Your Matches: '),
                  TextSpan(
                    text: '$count',
                    style: textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              IconlyLight.search,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: firebaseService.getAllMatchesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No matches yet.'));
          }

          _matches = snapshot.data!;

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: _matches.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _matches.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final matchData = _matches[index].data() as Map<String, dynamic>;
              return _buildMatchItem(matchData, textTheme);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
        },
      ),
    );
  }

  Widget _buildMatchItem(Map<String, dynamic> match, TextTheme textTheme) {
    final interestsData = match['hobbies'];
    // final interests = interestsData is List
    //     ? interestsData.join(', ')
    //     : 'No interests listed';
    final age = _calculateAge(match['dateOfBirth']);

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(
          match['profileImageUrl'] ??
              'https://i.pravatar.cc/150?u=${match['uid']}',
        ),
      ),
      title: Text(
        '${match['fullName'] ?? 'N/A'}, $age',
        style: textTheme.labelLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(interestsData, style: textTheme.bodySmall),
      trailing: const Icon(
        IconlyLight.message,
        color: AppColors.primaryRed,
        size: 20,
      ),
      onTap: () {
        final otherUser = ChatUser(
          uid: match['uid'],
          name: match['fullName'] ?? 'No Name',
          avatarUrl:
              match['profileImageUrl'] ??
              'https://i.pravatar.cc/150?u=${match['uid']}',
        );

        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: ConversationScreen(otherUser: otherUser),
          withNavBar: false,
        );
      },
    );
  }
}
