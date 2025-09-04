import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/viewmodels/inapp_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

enum SubscriptionPlan { monthly, weekly }

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Package? _selectedPackage;
  bool _isTrialEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      );
      if (provider.offerings.isEmpty) {
        provider.fetchOfferings();
      }
    });
  }

  void _onSubscribePressed() async {
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a plan.')));
      return;
    }

    final provider = Provider.of<SubscriptionProvider>(context, listen: false);
    final success = await provider.purchasePackage(_selectedPackage!);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
            Text(
              'Time to give yourself the good stuff you deserve.',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
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
            if (subscriptionProvider.isLoading &&
                subscriptionProvider.offerings.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (subscriptionProvider.offerings.isNotEmpty)
              _buildSubscriptionCards(textTheme, subscriptionProvider)
            else
              const Center(child: Text('No subscription plans available.')),
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
              onPressed:
                  _selectedPackage == null || subscriptionProvider.isLoading
                  ? null
                  : _onSubscribePressed,
              child: subscriptionProvider.isLoading
                  ? const Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Handle Restore Purchases
                },
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

  Widget _buildSubscriptionCards(
    TextTheme textTheme,
    SubscriptionProvider provider,
  ) {
    // This logic assumes your RevenueCat offering has packages with identifiers
    // that contain "monthly" or "weekly". Adjust if your identifiers are different.
    final offerings = provider.offerings.firstOrNull;
    if (offerings == null) return const SizedBox.shrink();

    final monthlyPackage = offerings.availablePackages.firstWhere(
      (p) => p.identifier.contains('monthly'),
      orElse: () => offerings.monthly!,
    );
    final weeklyPackage = offerings.availablePackages.firstWhere(
      (p) => p.identifier.contains('weekly'),
      orElse: () => offerings.weekly!,
    );

    return Column(
      children: [
        if (monthlyPackage != null)
          _buildMonthlyPlanCard(textTheme, monthlyPackage),
        const SizedBox(height: 12),
        if (weeklyPackage != null)
          _buildWeeklyPlanCard(textTheme, weeklyPackage),
      ],
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
        Image.asset('images/backgrounds/ratings_4.png', height: 74),
      ],
    );
  }

  Widget _buildMonthlyPlanCard(TextTheme textTheme, Package package) {
    bool isSelected = _selectedPackage == package;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => setState(() => _selectedPackage = package),
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
                          package.storeProduct.title,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryRed,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text.rich(
                          TextSpan(
                            text: package.storeProduct.priceString,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: ' / month',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          package.storeProduct.description,
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Radio<Package?>(
                    value: package,
                    groupValue: _selectedPackage,
                    onChanged: (value) {
                      setState(() => _selectedPackage = value);
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

  Widget _buildWeeklyPlanCard(TextTheme textTheme, Package package) {
    bool isSelected = _selectedPackage == package;
    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = package),
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
                      package.storeProduct.title,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        text: package.storeProduct.priceString,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '/ week',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Text('Try free trial', style: textTheme.bodySmall),
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
              Radio<Package?>(
                value: package,
                groupValue: _selectedPackage,
                onChanged: (value) {
                  setState(() => _selectedPackage = value);
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
