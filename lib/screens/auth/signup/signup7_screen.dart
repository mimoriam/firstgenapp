import 'package:firstgenapp/screens/auth/signup/signup8_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class Signup7Screen extends StatefulWidget {
  const Signup7Screen({super.key});

  @override
  State<Signup7Screen> createState() => _Signup7ScreenState();
}

class _Signup7ScreenState extends State<Signup7Screen> {
  final Set<String> _selectedValues = {
    'Family first',
    'Community service',
    'Hard work & ambition',
  };

  final List<String> _valueOptions = [
    'Family first',
    'Education & growth',
    'Community service',
    'Honesty & integrity',
    'Hard work & ambition',
    'Respect for elders',
  ];

  void _onNextPressed() {
    debugPrint("Selected Values: $_selectedValues");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup8Screen()));
    }
  }

  void _onValueSelected(bool selected, String value) {
    setState(() {
      if (selected) {
        if (_selectedValues.length < 3) {
          _selectedValues.add(value);
        }
      } else {
        _selectedValues.remove(value);
      }
    });
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
                        'Values & Beliefs',
                        // UPDATED: Used new title style
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'What are your core values? (Select your top 3)',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildValueChips(),
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

  Widget _buildValueChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _valueOptions.map((value) {
        final isSelected = _selectedValues.contains(value);
        return ChoiceChip(
          label: Text(value),
          selected: isSelected,
          onSelected: (selected) => _onValueSelected(selected, value),
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
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
                  text: '7',
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