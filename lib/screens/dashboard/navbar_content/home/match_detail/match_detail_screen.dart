import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/conversation/conversation_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:iconly/iconly.dart';
import 'dart:ui';
import 'package:country_picker/country_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class MatchDetailScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final bool isMatch;

  const MatchDetailScreen({
    super.key,
    required this.userProfile,
    this.isMatch = false,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool _isNowMatched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: Stack(
        children: [
          _buildBackgroundImage(widget.userProfile['imageUrl']),
          _buildBottomInfoCard(context),
          _buildOverlayContent(context),
          _buildTopBar(context),
          _buildActionButtonsWrapper(context),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
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
                    '${widget.userProfile['distance'] ?? 2.5} km',
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
              ? NetworkImage(imageUrl) as ImageProvider
              : const AssetImage('images/backgrounds/match_bg.png'),
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

  Widget _buildBottomInfoCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.43,
        width: double.infinity,
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
                _buildSectionTitle('About', context),
                const SizedBox(height: 8),
                Text(
                  widget.userProfile['about'] ?? 'No bio yet.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Languages', context),
                const SizedBox(height: 12),
                _buildChipGroup(widget.userProfile['languages'] ?? [], context),
                const SizedBox(height: 20),
                _buildSectionTitle('Interest', context),
                const SizedBox(height: 12),
                _buildChipGroup(widget.userProfile['interests'] ?? [], context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final country = Country.tryParse(widget.userProfile['countryCode'] ?? '');

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: 24,
      right: 24,
      child: Column(
        children: [
          Text(
            '${widget.userProfile['name'] ?? 'N/A'}, ${widget.userProfile['age'] ?? 'N/A'}',
            textAlign: TextAlign.center,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.userProfile['profession'] ?? 'N/A'}  |  ${country?.flagEmoji ?? ''} ${country?.name ?? 'N/A'}',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchIndicator(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMatchIndicator(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matchPercentage = widget.userProfile['matchPercentage'] ?? 0.80;
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

  Widget _buildActionButtonsWrapper(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
      future: firebaseService.getUserProfile(),
      builder: (context, snapshot) {
        // Show a loader while fetching the profile, unless we already know it's a match
        // from a super like or the incoming widget property.
        if (snapshot.connectionState == ConnectionState.waiting &&
            !_isNowMatched &&
            !widget.isMatch) {
          return const Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Determine match status from all possible sources
        final matches =
            snapshot.data?.data()?['matches'] as Map<String, dynamic>? ?? {};
        final bool isActuallyMatched = matches.containsKey(
          widget.userProfile['uid'],
        );
        final bool isMatched =
            widget.isMatch || _isNowMatched || isActuallyMatched;

        return _buildActionButtons(context, isMatched: isMatched);
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, {required bool isMatched}) {
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
                  if (!isMatched) ...[
                    _buildCircleButton(
                      icon: Icons.close,
                      bgColor: AppColors.primaryBackground,
                      iconColor: AppColors.textSecondary,
                      size: 62,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (isMatched)
                    _buildCircleButton(
                      icon: IconlyBold.message,
                      bgColor: AppColors.textPrimary,
                      iconColor: AppColors.primaryBackground,
                      size: 62,
                      onPressed: () {
                        final otherUser = ChatUser(
                          uid: widget.userProfile['uid'],
                          name: widget.userProfile['name'] ?? 'No Name',
                          avatarUrl:
                              widget.userProfile['imageUrl'] ??
                              'https://picsum.photos/seed/error/200/200',
                        );
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ConversationScreen(otherUser: otherUser),
                          withNavBar: false,
                        );
                      },
                    )
                  else ...[
                    if (subscriptionProvider.isPremium) ...[
                      _buildCircleButton(
                        icon: TablerIcons.sparkles,
                        isGradient: true,
                        iconColor: AppColors.primaryBackground,
                        size: 62,
                        onPressed: () async {
                          try {
                            await firebaseService.superLikeUser(
                              widget.userProfile['uid'],
                            );
                            if (mounted) {
                              setState(() => _isNowMatched = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "It's a Match! You can now message them.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
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
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    _buildCircleButton(
                      icon: Icons.favorite,
                      isGradient: true,
                      iconColor: AppColors.primaryBackground,
                      size: 62, // Make like button bigger
                      onPressed: () {
                        firebaseService.likeUser(widget.userProfile['uid']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Liked!"),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
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

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildChipGroup(List<dynamic> items, BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items
          .map((item) => _buildChip(item.toString(), context))
          .toList(),
    );
  }

  Widget _buildChip(String label, BuildContext context) {
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
