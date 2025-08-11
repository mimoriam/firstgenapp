import 'package:firstgenapp/screens/auth/signup/signup7_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Signup6Screen extends StatefulWidget {
  const Signup6Screen({super.key});

  @override
  State<Signup6Screen> createState() => _Signup6ScreenState();
}

class _Signup6ScreenState extends State<Signup6Screen> {
  final TextEditingController _musicController = TextEditingController();
  final Set<String> _selectedArts = {
    'Traditional dance',
    'Literature & poetry',
  };

  final List<String> _artOptions = [
    'Traditional dance',
    'Theater & plays',
    'Literature & poetry',
    'Visual arts',
    'International cinema',
  ];

  @override
  void dispose() {
    _musicController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    debugPrint("Music: ${_musicController.text}");
    debugPrint("Selected Arts: $_selectedArts");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup7Screen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Begin Your Journey',
                          // UPDATED: Used smaller headline style
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create your First Gen account and begin your cultural journey.',
                          // UPDATED: Used smaller body style for consistency
                          style: textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        Text(
                          'Music & Arts',
                          // UPDATED: Used new title style
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What music moves your soul?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildMusicInput(),
                        const SizedBox(height: 20),
                        Text(
                          'Cultural arts you enjoy',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildArtChips(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                _buildBottomNav(textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMusicInput() {
    return TextField(
      controller: _musicController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'e.g., Bollywood classics, K-pop etc....',
        // UPDATED: Reduced hint text size
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        alignLabelWithHint: true,
        // UPDATED: Slightly reduced vertical padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.inputBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildArtChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _artOptions.map((art) {
        final isSelected = _selectedArts.contains(art);
        return ChoiceChip(
          label: Text(art),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedArts.add(art);
              } else {
                _selectedArts.remove(art);
              }
            });
          },
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
          ),
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(
              color: isSelected ? AppColors.primaryRed : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          showCheckmark: false,
          // UPDATED: Reduced padding for compact chip
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              children: const <TextSpan>[
                TextSpan(
                  text: '6',
                  style: TextStyle(color: AppColors.primaryOrange),
                ),
                TextSpan(
                  text: ' out of 10',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _onNextPressed,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryRed, AppColors.primaryOrange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}