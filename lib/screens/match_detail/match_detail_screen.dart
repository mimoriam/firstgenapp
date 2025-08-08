import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'dart:ui'; // Required for ImageFilter

class MatchDetailScreen extends StatefulWidget {
  const MatchDetailScreen({super.key});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  // Mock data for the user profile
  final Map<String, dynamic> userProfile = {
    'name': 'Alfredo Calzoni',
    'age': 20,
    'profession': 'Doctor',
    'nationality': 'German',
    'flag': '🇩🇪',
    'distance': 2.5,
    'matchPercentage': 0.80,
    'imageUrl': 'images/backgrounds/match_bg.png',
    'about': 'A good listener. I love having a good talk to know each other\'s side 😍.',
    'languages': ['English', 'German'],
    'interests': ['Reading', 'Photography', 'Music', 'Travel'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildBottomInfoCard(),
          _buildOverlayContent(),
          _buildTopBar(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Builds the top bar with the back arrow and distance chip.
  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${userProfile['distance']} km',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the full-screen background image with a gradient overlay.
  Widget _buildBackgroundImage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(userProfile['imageUrl']),
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

  /// Builds the fixed bottom card with user details.
  Widget _buildBottomInfoCard() {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // UPDATED: Reduced height for compactness
        height: MediaQuery.of(context).size.height * 0.43,
        decoration: const BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            // UPDATED: Reduced top and bottom padding
            padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 100.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('About'),
                const SizedBox(height: 8),
                Text(userProfile['about'], style: textTheme.bodySmall),
                // UPDATED: Reduced spacing
                const SizedBox(height: 20),
                _buildSectionTitle('Languages'),
                const SizedBox(height: 12),
                _buildChipGroup(userProfile['languages']),
                // UPDATED: Reduced spacing
                const SizedBox(height: 20),
                _buildSectionTitle('Interest'),
                const SizedBox(height: 12),
                _buildChipGroup(userProfile['interests']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the content that overlays the background image.
  Widget _buildOverlayContent() {
    final textTheme = Theme.of(context).textTheme;
    return Positioned(
      // UPDATED: Adjusted position to match new card height
      bottom: MediaQuery.of(context).size.height * 0.43,
      left: 24,
      right: 24,
      child: Column(
        children: [
          Text(
            '${userProfile['name']}, ${userProfile['age']}',
            textAlign: TextAlign.center,
            // UPDATED: Reduced font size
            style: textTheme.headlineLarge?.copyWith(color: Colors.white, fontSize: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '${userProfile['profession']} | ${userProfile['flag']} ${userProfile['nationality']}',
            // UPDATED: Reduced font size
            style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          // UPDATED: Reduced spacing
          const SizedBox(height: 16),
          _buildMatchIndicator(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Builds the match percentage indicator button.
  Widget _buildMatchIndicator() {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      // UPDATED: Reduced padding
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
            // UPDATED: Reduced size
            width: 36,
            height: 36,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: userProfile['matchPercentage'],
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                ),
                Center(
                  child: Text(
                    '${(userProfile['matchPercentage'] * 100).toInt()}%',
                    // UPDATED: Reduced font size
                    style: textTheme.bodySmall
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Match',
            // UPDATED: Reduced font size
            style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Builds the action buttons with blur effect at the bottom of the screen.
  Widget _buildActionButtons() {
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
              // UPDATED: Reduced padding
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
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
                    // UPDATED: Reduced size
                    size: 52,
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: Icons.mail_outline,
                    bgColor: AppColors.textPrimary,
                    iconColor: AppColors.primaryBackground,
                    // UPDATED: Reduced size
                    size: 62,
                  ),
                  const SizedBox(width: 12),
                  _buildCircleButton(
                    icon: Icons.favorite,
                    isGradient: true,
                    iconColor: AppColors.primaryBackground,
                    // UPDATED: Reduced size
                    size: 52,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper to build a single circular action button.
  Widget _buildCircleButton({
    required IconData icon,
    Color? bgColor,
    bool isGradient = false,
    required Color iconColor,
    required double size,
  }) {
    return Container(
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
    );
  }

  /// Helper to build a section title.
  Widget _buildSectionTitle(String title) {
    // UPDATED: Inherited from theme
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  /// Helper to build a group of chips.
  Widget _buildChipGroup(List<String> items) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: items.map((item) => _buildChip(item)).toList(),
    );
  }

  /// Helper to build a single styled chip.
  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppColors.primaryBackground,
      side: const BorderSide(color: AppColors.inputBorder),
      // UPDATED: Compacted chip style
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    );
  }
}