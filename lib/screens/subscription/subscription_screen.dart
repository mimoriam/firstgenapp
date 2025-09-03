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

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      ).fetchOfferings();
    });
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
            if (subscriptionProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (subscriptionProvider.offerings.isNotEmpty)
              _buildSubscriptionOptions(subscriptionProvider)
            else
              const Center(child: Text('No subscription plans available.')),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Handle Restore Purchases
                },
                child: Text(
                  'Restore Purchases',
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

  Widget _buildSubscriptionOptions(SubscriptionProvider provider) {
    // Assuming your default offering has monthly and weekly packages
    final offering = provider.offerings.firstWhere(
      (o) => o.identifier == 'default',
      orElse: () => provider.offerings.first,
    );

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: offering.availablePackages.length,
      itemBuilder: (context, index) {
        final package = offering.availablePackages[index];
        return _buildPlanCard(provider, package);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }

  Widget _buildPlanCard(SubscriptionProvider provider, Package package) {
    final textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () async {
        final success = await provider.purchasePackage(package);
        if (success && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
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
                  Text(
                    package.storeProduct.priceString,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            provider.isLoading
                ? const CircularProgressIndicator()
                : const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryRed,
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
        Image.asset('images/backgrounds/ratings_4.png', height: 74),
      ],
    );
  }
}
