import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:iconly/iconly.dart';
import 'dart:ui';
import 'package:provider/provider.dart';

class MatchDetailForSearchScreen extends StatefulWidget {
  final String? continent;
  final List<String> languages;
  final String? generation;
  final String? gender;
  final int minAge;
  final int maxAge;
  final List<String> professions;
  final List<String> interests;
  final Function(ChatUser user) onUserSelected;

  const MatchDetailForSearchScreen({
    super.key,
    required this.continent,
    required this.languages,
    this.generation,
    this.gender,
    required this.minAge,
    required this.maxAge,
    required this.professions,
    required this.interests,
    required this.onUserSelected,
  });

  @override
  State<MatchDetailForSearchScreen> createState() =>
      _MatchDetailForSearchScreenState();
}

class _MatchDetailForSearchScreenState
    extends State<MatchDetailForSearchScreen> {
  late Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _usersFuture;
  final CardSwiperController _swiperController = CardSwiperController();
  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    _usersFuture = firebaseService.searchUsersStrict(
      continent: widget.continent,
      languages: widget.languages,
      generation: widget.generation,
      gender: widget.gender,
      minAge: widget.minAge,
      maxAge: widget.maxAge,
      professions: widget.professions,
      interests: widget.interests,
    );
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _handleLike(int index) {
    final user = _users[index];
    debugPrint("Liked ${user['fullName']}");
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    firebaseService.addRecentMatch(user['uid']);
  }

  void _handleDiscard(int index) {
    final user = _users[index];
    debugPrint("Discarded ${user['fullName']}");
  }

  void _onMessage(int index) {
    final user = _users[index];
    final otherUser = ChatUser(
      uid: user['uid'],
      name: user['fullName'] ?? 'No Name',
      avatarUrl: user['profileImageUrl'] ?? '',
    );
    widget.onUserSelected(otherUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users match your criteria.'));
          }

          _users = snapshot.data!.map((doc) => doc.data()).toList();

          return Material(
            color: AppColors.secondaryBackground,
            child: ClipRect(
              child: Stack(
                children: [
                  _buildBlurredBackground(),
                  if (_isFinished)
                    Center(
                      child: Text(
                        'No more users found.',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  CardSwiper(
                    controller: _swiperController,
                    cardsCount: _users.length,
                    onSwipe: _onSwipe,
                    onUndo: _onUndo,
                    numberOfCardsDisplayed: 1,
                    backCardOffset: Offset.zero,
                    padding: EdgeInsets.zero,
                    allowedSwipeDirection: const AllowedSwipeDirection.none(),
                    cardBuilder:
                        (
                          context,
                          index,
                          horizontalThresholdPercentage,
                          verticalThresholdPercentage,
                        ) {
                          final userProfile = _users[index];
                          return _buildMatchCard(userProfile, index);
                        },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlurredBackground() {
    int backgroundIndex = _currentIndex;
    if (!_isFinished) {
      backgroundIndex = _currentIndex + 1;
      if (backgroundIndex >= _users.length) {
        backgroundIndex = _currentIndex;
      }
    }

    if (_users.isEmpty) {
      return Container(color: AppColors.secondaryBackground);
    }

    final backgroundUserProfile = _users[backgroundIndex];
    final imageUrl = backgroundUserProfile['profileImageUrl'];
    final bool isNetworkUrl = imageUrl != null && imageUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isNetworkUrl
              ? NetworkImage(imageUrl)
              : const AssetImage('images/backgrounds/match_bg.png')
                    as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(color: Colors.black.withOpacity(0.2)),
      ),
    );
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      _currentIndex = currentIndex ?? previousIndex;
      if (currentIndex == null) {
        _isFinished = true;
      }
    });

    if (direction == CardSwiperDirection.right) {
      _handleLike(previousIndex);
    } else if (direction == CardSwiperDirection.left) {
      _handleDiscard(previousIndex);
    }
    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    setState(() {
      _currentIndex = currentIndex;
      _isFinished = false;
    });
    debugPrint('The card $currentIndex was undod from the ${direction.name}');
    return true;
  }

  List<String> _parseList(dynamic data) {
    if (data is List) {
      return List<String>.from(data.map((item) => item.toString()));
    }
    if (data is String) {
      return data
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  Widget _buildMatchCard(Map<String, dynamic> userProfile, int index) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackgroundImage(userProfile['profileImageUrl']),
          _buildBottomInfoCard(userProfile),
          _buildOverlayContent(userProfile),
          _buildTopBar(userProfile),
          _buildActionButtons(index),
        ],
      ),
    );
  }

  Widget _buildTopBar(Map<String, dynamic> userProfile) {
    return const SizedBox.shrink();
  }

  Widget _buildBackgroundImage(String? imageUrl) {
    final bool isNetworkUrl = imageUrl != null && imageUrl.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: isNetworkUrl
              ? NetworkImage(imageUrl)
              : const AssetImage('images/backgrounds/match_bg.png')
                    as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.4, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomInfoCard(Map<String, dynamic> userProfile) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.43,
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('About'),
                const SizedBox(height: 8),
                Text(
                  userProfile['bio'] ?? 'No bio yet.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Languages'),
                const SizedBox(height: 12),
                _buildChipGroup(_parseList(userProfile['languages'])),
                const SizedBox(height: 20),
                _buildSectionTitle('Interest'),
                const SizedBox(height: 12),
                _buildChipGroup(_parseList(userProfile['hobbies'])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent(Map<String, dynamic> userProfile) {
    final textTheme = Theme.of(context).textTheme;
    final dob = (userProfile['dateOfBirth'] as Timestamp?)?.toDate();
    final age = dob != null
        ? (DateTime.now().difference(dob).inDays / 365).floor()
        : 'N/A';

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: 24,
      right: 24,
      child: Column(
        children: [
          Text(
            '${userProfile['fullName'] ?? 'N/A'}, $age',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${userProfile['profession'] ?? 'N/A'}  |  ${userProfile['culturalHeritage'] ?? 'N/A'}',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchIndicator(userProfile),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMatchIndicator(Map<String, dynamic> userProfile) {
    final textTheme = Theme.of(context).textTheme;
    final matchPercentage = userProfile['matchPercentage'] ?? 0.80;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: matchPercentage,
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryRed,
                  ),
                ),
                Center(
                  child: Text(
                    '${(matchPercentage * 100).toInt()}%',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Match',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int index) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCircleButton(
                    icon: Icons.close,
                    bgColor: AppColors.primaryBackground,
                    iconColor: AppColors.textSecondary,
                    size: 60,
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.left),
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: IconlyBold.message,
                    bgColor: AppColors.textPrimary,
                    iconColor: AppColors.primaryBackground,
                    size: 60,
                    onPressed: () => _onMessage(index),
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: Icons.favorite,
                    isGradient: true,
                    iconColor: AppColors.primaryBackground,
                    size: 60,
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.right),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    Color? bgColor,
    bool isGradient = false,
    required Color iconColor,
    required double size,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: isGradient
              ? const LinearGradient(
                  colors: [AppColors.primaryOrange, AppColors.primaryRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildChipGroup(List<String> items) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) => _buildChip(item)).toList(),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryBackground,
      side: const BorderSide(color: AppColors.inputBorder),
      labelStyle: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}
