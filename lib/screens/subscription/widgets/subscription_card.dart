import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'dart:math' as math;

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.priceSuffix,
    required this.features,
    this.isPopular = false,
    this.isBestValue = false,
    this.cardColor = Colors.white,
    this.buttonGradient,
    this.titleIcon,
    this.isActive = false,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String price;
  final String priceSuffix;
  final List<Map<String, dynamic>> features;
  final bool isPopular;
  final bool isBestValue;
  final Color cardColor;
  final LinearGradient? buttonGradient;
  final IconData? titleIcon;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screen = MediaQuery.of(context).size;
    // Remove unused calculation since we're now using flexible layout

    // Remove box shadows as requested
    final boxShadow = <BoxShadow>[];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cardColor.withOpacity(0.98),
            cardColor.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: boxShadow,
        border: Border.all(
          color: isActive ? AppColors.primaryRed.withOpacity(0.12) : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative top-right subtle pattern / circle
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.06),
                    AppColors.primaryRed.withOpacity(0.06),
                  ],
                ),
              ),
            ),
          ),

          // Fix overlapping tags by positioning them properly
          if (isBestValue && !isPopular)
            Positioned(
              top: -8,
              right: 12,
              child: _buildCornerTag('Best Value', Colors.orangeAccent),
            ),
          if (isPopular && !isBestValue)
            Positioned(
              top: -8,
              right: 12,
              child: _buildCornerTag('MOST POPULAR', AppColors.primaryRed),
            ),
          if (isBestValue && isPopular)
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCornerTag('Best Value', Colors.orangeAccent),
                  _buildCornerTag('POPULAR', AppColors.primaryRed),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon circle
                    if (titleIcon != null)
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: buttonGradient ??
                              LinearGradient(
                                colors: [AppColors.primaryBlue.withOpacity(0.9), AppColors.primaryRed.withOpacity(0.9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                          // Remove box shadow
                        ),
                        child: Icon(titleIcon, color: Colors.white, size: 22),
                      )
                    else
                      const SizedBox(width: 0),
                    const SizedBox(width: 12),
                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price block
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: price,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: '  ',
                                style: textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          priceSuffix,
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Features list - now flexible and responsive
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: features.length,
                    itemBuilder: (context, idx) {
                      final feature = features[idx];
                      final icon = feature['icon'];
                      final text = feature['text'] as String;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bullet
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBackground,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: AppColors.dotInactive.withOpacity(0.12)),
                                // Remove box shadow
                              ),
                              child: Center(
                                child: icon is IconData
                                    ? Icon(icon, color: AppColors.primaryRed, size: 18)
                                    : (icon is String
                                        ? SvgPicture.asset(icon, height: 18, width: 18, color: AppColors.primaryOrange)
                                        : const SizedBox.shrink()),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        // Remove box shadow
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}