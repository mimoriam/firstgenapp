import 'package:firstgenapp/screens/auth/signup/signup5_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class Signup4Screen extends StatefulWidget {
  const Signup4Screen({super.key});

  @override
  State<Signup4Screen> createState() => _Signup4ScreenState();
}

class _Signup4ScreenState extends State<Signup4Screen> {
  double _familyImportanceValue = 0.4;
  final Set<String> _selectedTraditions = {
    'Cultural holiday',
    'Food traditions',
  };

  final List<String> _traditionOptions = [
    'Cultural holiday',
    'Food traditions',
    'Religious practice',
    'Music & dance',
  ];

  void _onNextPressed() {
    debugPrint("Family Importance: $_familyImportanceValue");
    debugPrint("Selected Traditions: $_selectedTraditions");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup5Screen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
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
                        'Family & Traditions',
                        // UPDATED: Used new title style
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'How important is family in your life?',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildFamilySlider(),
                      const SizedBox(height: 20),
                      Text(
                        'Which traditions are important to you?',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildTraditionChips(),
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
    );
  }

  Widget _buildFamilySlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryRed,
            inactiveTrackColor: AppColors.inputBorder,
            thumbColor: AppColors.primaryRed,
            overlayColor: AppColors.primaryRed.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 15.0),
          ),
          child: Slider(
            value: _familyImportanceValue,
            onChanged: (newValue) {
              setState(() {
                _familyImportanceValue = newValue;
              });
            },
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Not Important',
                // UPDATED: Used smaller text style
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Important',
                // UPDATED: Used smaller text style
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTraditionChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _traditionOptions.map((tradition) {
        final isSelected = _selectedTraditions.contains(tradition);
        return ChoiceChip(
          label: Text(tradition),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTraditions.add(tradition);
              } else {
                _selectedTraditions.remove(tradition);
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
                  text: '4',
                  style: TextStyle(color: AppColors.primaryOrange),
                ),
                TextSpan(
                  text: ' out of 10',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
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
            child: FloatingActionButton(
              onPressed: _onNextPressed,
              elevation: 0,
              enableFeedback: false,
              backgroundColor: Colors.transparent,
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}