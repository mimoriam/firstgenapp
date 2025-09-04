import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:firstgenapp/viewmodels/inapp_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

enum SubscriptionPlan { monthly, weekly }

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  SubscriptionPlan _selectedPlan = SubscriptionPlan.monthly;
  bool _isTrialEnabled = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Get the subscription provider to check loading state
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    return Scaffold(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SizedBox(height: 8),
            Text(
              'Time to give yourself the good stuff you deserve.',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              // icon: Iconsax.global,
              icon: TablerIcons.world_bolt,
              title: 'Unlimited Connections',
              subtitle: 'Meet more people from around the globe',
            ),
            _buildFeatureItem(
              icon: HugeIcons.strokeRoundedUserLock01,
              title: 'Join Exclusive Communities',
              subtitle: 'Access private cultural spaces',
            ),
            _buildFeatureItem(
              icon: HugeIcons.strokeRoundedUserGroup,
              title: 'Host & Create Events',
              subtitle: 'Lead your own meetups',
            ),
            _buildFeatureItem(
              icon: HugeIcons.strokeRoundedUserSearch01,
              title: 'Advanced Search Filters',
              subtitle: "Find exactly who you're looking for",
            ),
            _buildFeatureItem(
              icon: TablerIcons.message_2_bolt,
              title: 'Ad-Free Experience',
              subtitle: 'Enjoy a clean, distraction-free feed',
            ),
            const SizedBox(height: 12),
            _buildRatingsSection(),
            const SizedBox(height: 12),
            _buildMonthlyPlanCard(textTheme),
            const SizedBox(height: 12),
            _buildWeeklyPlanCard(textTheme),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, color: AppColors.primaryRed, size: 20),
                SizedBox(width: 8),
                Text(
                  'No Payment Due Today',
                  style: TextStyle(color: AppColors.primaryRed),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GradientButton(
              text: 'Subscribe Now',
              child: subscriptionProvider.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
              onPressed: subscriptionProvider.isLoading
                  ? null
                  : () {
                      // Determine the selected plan as a string
                      final plan = _selectedPlan == SubscriptionPlan.monthly
                          ? 'monthly'
                          : 'weekly';

                      // Call the purchasePackage method from the provider
                      Provider.of<SubscriptionProvider>(
                        context,
                        listen: false,
                      ).purchasePackage(plan).then((success) {
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Subscription successful!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.of(context).pop();
                        } else if (!success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Subscription failed. Please try again.',
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      });
                    },
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Cancel anytime',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: '$title – ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.3,
                  color: AppColors.primaryRed,
                ),
                children: [
                  TextSpan(
                    text: subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('images/backgrounds/ratings_3.png', height: 74),
        // const SizedBox(width: 10),
        Image.asset('images/backgrounds/ratings_4.png', height: 74),
      ],
    );
  }

  Widget _buildMonthlyPlanCard(TextTheme textTheme) {
    bool isSelected = _selectedPlan == SubscriptionPlan.monthly;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedPlan = SubscriptionPlan.monthly),
          child: Container(
            padding: const EdgeInsets.all(2), // This creates the border width
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [AppColors.primaryOrange, AppColors.primaryRed],
                    )
                  : null,
              color: isSelected ? null : Colors.grey.shade300, // Border color
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '88% off',
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text: '\$4.99',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: '/ month',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('only 4.99 per month', style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Radio<SubscriptionPlan>(
                    value: SubscriptionPlan.monthly,
                    groupValue: _selectedPlan,
                    onChanged: (value) {
                      setState(() => _selectedPlan = value!);
                    },
                    activeColor: AppColors.primaryRed,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'MOST POPULAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlanCard(TextTheme textTheme) {
    bool isSelected = _selectedPlan == SubscriptionPlan.weekly;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = SubscriptionPlan.weekly),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.primaryOrange, AppColors.primaryRed],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '88% off',
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: '9.99',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '/Week',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('Try free trial', style: textTheme.bodySmall),
                        // const SizedBox(width: 4),
                        Transform.scale(
                          scale: 0.6,
                          child: Switch(
                            value: _isTrialEnabled,
                            onChanged: (value) {
                              setState(() => _isTrialEnabled = value);
                            },
                            activeColor: AppColors.primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Radio<SubscriptionPlan>(
                value: SubscriptionPlan.weekly,
                groupValue: _selectedPlan,
                onChanged: (value) {
                  setState(() => _selectedPlan = value!);
                },
                activeColor: AppColors.primaryRed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
