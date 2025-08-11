import 'package:firstgenapp/screens/auth/signup/signup10_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Signup9Screen extends StatefulWidget {
  const Signup9Screen({super.key});

  @override
  State<Signup9Screen> createState() => _Signup9ScreenState();
}

class _Signup9ScreenState extends State<Signup9Screen> {
  final TextEditingController _dealBreakerController = TextEditingController();
  String? _selectedRelationship;
  double _importanceValue = 0.4;

  final List<String> _relationshipOptions = [
    'Friendship',
    'Networking',
    'Dating',
    'Cultural Exchange',
    'Community Support',
    'Not Sure Yet',
  ];

  @override
  void dispose() {
    _dealBreakerController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    debugPrint("Seeking: $_selectedRelationship");
    debugPrint("Importance: $_importanceValue");
    debugPrint("Deal-breakers: ${_dealBreakerController.text}");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup10Screen()));
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                          'What you are Looking For',
                          // UPDATED: Used new title style
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What kind of relationship are you seeking?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _buildRelationshipChips(),
                        const SizedBox(height: 20),
                        Text(
                          'How important is that your partner shares your cultural background?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _buildImportanceSlider(),
                        const SizedBox(height: 20),
                        Text(
                          'What are your absolute deal-breakers?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 10),
                        _buildDealBreakerInput(),
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

  Widget _buildRelationshipChips() {
    return Wrap(
      spacing: 5.0,
      runSpacing: 10.0,
      children: _relationshipOptions.map((relationship) {
        final isSelected = _selectedRelationship == relationship;
        return ChoiceChip(
          label: Text(relationship),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedRelationship = selected ? relationship : null;
            });
          },
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
          ),
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: isSelected ? AppColors.primaryRed : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          showCheckmark: false,
          // UPDATED: Reduced padding for compact chip
          padding: const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 8.0,
          ),
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
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
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

  Widget _buildDealBreakerInput() {
    return TextField(
      controller: _dealBreakerController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'e.g, smoking, dishonesty, lack of family respect....',
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

  Widget _buildBottomNav(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 24.0, left: 10),
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
                  text: '9',
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