import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>? _usersFuture;
  final CardSwiperController _swiperController = CardSwiperController();

  List<Map<String, dynamic>> _users = [];
  int _currentIndex = 0;
  bool _isFinished = false;
  bool _isSuperLiking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProfileViewModel = Provider.of<UserProfileViewModel>(context);

    if (_usersFuture == null && userProfileViewModel.userProfileData != null) {
      setState(() {
        _usersFuture = _fetchUsersBasedOnPreferences(
          userProfileViewModel.userProfileData!,
        );
      });
    }
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _fetchUsersBasedOnPreferences(Map<String, dynamic> searchUserData) async {
    final String? continent = searchUserData['regionFocus'];
    final String? generation = searchUserData['lookingForGeneration'];
    final String? gender = searchUserData['searchGender'];
    final int minAge = searchUserData['searchMinAge'] ?? 18;
    final int maxAge = searchUserData['searchMaxAge'] ?? 100;
    final List<String> languages = List<String>.from(
      searchUserData['searchLanguages'] ?? [],
    );
    final List<String> professions = List<String>.from(
      searchUserData['searchProfessions'] ?? [],
    );
    final List<String> interests = List<String>.from(
      searchUserData['searchInterests'] ?? [],
    );

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return await firebaseService.searchUsersStrict(
      continent: continent,
      generation: generation,
      gender: gender,
      minAge: minAge,
      maxAge: maxAge,
      languages: languages,
      professions: professions,
      interests: interests,
    );
  }

  void _handleLike(int index) {
    final user = _users[index];
    debugPrint("Liked ${user['fullName']}");
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    firebaseService.likeUser(user['uid']);
  }

  void _handleDiscard(int index) {
    final user = _users[index];
    debugPrint("Discarded ${user['fullName']}");
  }

  void _onMessage(int index) async {
    final user = _users[index];
    final otherUser = ChatUser(
      uid: user['uid'],
      name: user['fullName'] ?? 'No Name',
      avatarUrl:
          user['profileImageUrl'] ?? 'https://picsum.photos/seed/error/200/200',
    );

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    await firebaseService.createMatch(otherUser.uid);
    firebaseService.addRecentUser(otherUser.uid);

    if (mounted) {
      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: ConversationScreen(otherUser: otherUser),
        withNavBar: false,
      );
    }
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

  @override
  Widget build(BuildContext context) {
    if (_usersFuture == null) {
      return const Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}\nPlease ensure your search preferences are set in your profile.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.secondaryBackground,
            body: Center(child: Text('No users match your criteria.')),
          );
        }

        _users = snapshot.data!.map((doc) => doc.data()).toList();

        return Material(
          color: AppColors.secondaryBackground,
          child: ClipRect(
            child: Stack(
              children: [
                if (_isFinished)
                  Center(
                    child: Text(
                      'No more users found.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: Colors.black, fontSize: 16),
                    ),
                  ),
                Visibility(
                  visible: !_isFinished,
                  child: CardSwiper(
                    isLoop: false,
                    controller: _swiperController,
                    cardsCount: _users.length,
                    onSwipe: _onSwipe,
                    onUndo: _onUndo,
                    numberOfCardsDisplayed: 1,
                    backCardOffset: Offset.zero,
                    padding: EdgeInsets.zero,
                    allowedSwipeDirection:
                        const AllowedSwipeDirection.symmetric(horizontal: true),
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
                ),
              ],
            ),
          ),
        );
      },
    );
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Iconsax.send_2_copy,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${userProfile['distance'] ?? 2.5} km',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
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
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.left),
                    size: 52,
                    bgColor: AppColors.primaryBackground,
                    child: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 52 * 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (subscriptionProvider.isPremium) ...[
                    _buildCircleButton(
                      size: 52,
                      isGradient: true,
                      onPressed: _isSuperLiking
                          ? null
                          : () async {
                              setState(() {
                                _isSuperLiking = true;
                              });
                              final user = _users[index];
                              try {
                                await firebaseService.superLikeUser(
                                  user['uid'],
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Super Like! It's a Match!",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _swiperController.swipe(
                                    CardSwiperDirection.right,
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Super Like failed: ${e.toString()}",
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSuperLiking = false;
                                  });
                                }
                              }
                            },
                      child: _isSuperLiking
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              TablerIcons.sparkles,
                              color: AppColors.primaryBackground,
                              size: 52 * 0.5,
                            ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  _buildCircleButton(
                    size: 62,
                    isGradient: true,
                    onPressed: () =>
                        _swiperController.swipe(CardSwiperDirection.right),
                    child: const Icon(
                      Icons.favorite,
                      color: AppColors.primaryBackground,
                      size: 62 * 0.5,
                    ),
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
    required Widget child,
    Color? bgColor,
    bool isGradient = false,
    required double size,
    required VoidCallback? onPressed,
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
        child: Center(child: child),
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
