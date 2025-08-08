import 'package:firstgenapp/screens/signup/signup6_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Signup5Screen extends StatefulWidget {
  const Signup5Screen({super.key});

  @override
  State<Signup5Screen> createState() => _Signup5ScreenState();
}

class _Signup5ScreenState extends State<Signup5Screen> {
  final TextEditingController _cuisineController = TextEditingController();
  final Set<String> _selectedDiets = {'Vegetarian', 'Halal'};

  final List<String> _dietOptions = [
    'Vegetarian',
    'Vegan',
    'Kosher',
    'Halal',
    'No restrictions',
  ];

  @override
  void dispose() {
    _cuisineController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    debugPrint("Cuisines: ${_cuisineController.text}");
    debugPrint("Selected Diets: $_selectedDiets");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup6Screen()));
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
                          'Food & Lifestyle',
                          // UPDATED: Used new title style
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What cuisines do you love?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildCuisineInput(),
                        const SizedBox(height: 20),
                        Text(
                          'Dietary preferences/restrictions',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildDietChips(),
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

  Widget _buildCuisineInput() {
    return TextField(
      controller: _cuisineController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'e.g., authentic Mexican food, Korean BBQ etc....',
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

  Widget _buildDietChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _dietOptions.map((diet) {
        final isSelected = _selectedDiets.contains(diet);
        return ChoiceChip(
          label: Text(diet),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDiets.add(diet);
              } else {
                _selectedDiets.remove(diet);
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
                  text: '5',
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