import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showExitConfirmationDialogForHome(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.primaryBackground,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.error.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high_rounded,
                color: colorScheme.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Do you want to exit\nthe app?",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  // UPDATED: Changed OutlinedButton to TextButton to match "Sign In" style
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Cancel",
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    text: 'Exit',
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    insets: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
