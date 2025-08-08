import 'package:flutter/material.dart';

/// A widget that represents a single page in the onboarding flow.
class OnboardingPage extends StatelessWidget {
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // A container to center the image content vertically.
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: 418,
        height: 435,
        // Using ClipRRect to apply the border radius to the image.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60.0),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}