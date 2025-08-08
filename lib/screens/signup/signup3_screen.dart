import 'package:firstgenapp/screens/signup/signup4_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class Signup3Screen extends StatefulWidget {
  const Signup3Screen({super.key});

  @override
  State<Signup3Screen> createState() => _Signup3ScreenState();
}

class _Signup3ScreenState extends State<Signup3Screen> {
  // UPDATED: Changed from Set to nullable String for single selection
  String? _selectedReligion;
  double _importanceValue = 0.5;

  final List<String> _religionOptions = [
    'Christianity',
    'Islam',
    'Hinduism',
    'Buddhism',
    'Judaism',
    'Spiritual',
    'Agnostic',
    'Atheist',
    'Other',
  ];

  void _onNextPressed() {
    debugPrint("Selected Religion: $_selectedReligion");
    debugPrint("Importance Level: $_importanceValue");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup4Screen()));
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
                        'Religion & Spirituality',
                        // UPDATED: Used new title style
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'What is your religion or spiritual background?',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildReligionChips(),
                      const SizedBox(height: 20),
                      Text(
                        'How important is sharing similar spiritual beliefs with a partner?',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildImportanceSlider(),
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

  Widget _buildReligionChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _religionOptions.map((religion) {
        // UPDATED: Logic for single selection
        final isSelected = _selectedReligion == religion;
        return ChoiceChip(
          label: Text(religion),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              // UPDATED: Set state for single selection
              if (selected) {
                _selectedReligion = religion;
              }
            });
          },
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
          selectedColor: AppColors.secondaryBackground,
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

  Widget _buildImportanceSlider() {
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
            value: _importanceValue,
            onChanged: (newValue) {
              setState(() {
                _importanceValue = newValue;
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
                  text: '3',
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