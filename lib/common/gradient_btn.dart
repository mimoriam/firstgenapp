import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? child;
  final LinearGradient? gradient;
  final double? insets;
  final double? fontSize;
 
  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.child,
    this.gradient,
    this.insets,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    // Get the base button text style from the theme
    final buttonTextStyle = Theme.of(
      context,
    ).elevatedButtonTheme.style?.textStyle?.resolve({});

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: insets ?? 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: gradient ??
              const LinearGradient(
                colors: [AppColors.primaryRed, AppColors.primaryOrange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
        ),
        child:
            child ??
            Text(
              text,
              textAlign: TextAlign.center,
              // Apply the theme style and override the color for this specific button
              style: buttonTextStyle?.copyWith(
                color: Colors.white,
                fontSize: fontSize ?? buttonTextStyle.fontSize,
              ),
            ),
      ),
    );
  }
}
