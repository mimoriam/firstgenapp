import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:firstgenapp/screens/subscription/widgets/subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  final int initialPage;
  const SubscriptionScreen({super.key, this.initialPage = 1});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}


class _SubscriptionScreenState extends State<SubscriptionScreen> {
  late int _currentPage;
  late PageController _pageController;

  // Define the plans shown in the PageView
  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'free',
      'title': 'Free',
      'subtitle': 'Start your dating journey with essential features',
      'price': '\$0',
      'priceSuffix': 'always free',
      'features': [
        {'icon': TablerIcons.user_search, 'text': 'Browse profiles in your area'},
        {'icon': TablerIcons.heart, 'text': '10 likes per day'},
        {'icon': TablerIcons.message_2, 'text': 'Message your matches'},
        {'icon': TablerIcons.filter, 'text': 'Basic search filters'},
        {'icon': TablerIcons.users, 'text': 'Join community groups'},
      ],
      'buttonText': 'Current Plan',
      'isPopular': false,
      'isBestValue': false,
      'cardColor': AppColors.primaryBackground,
      'buttonGradient': const LinearGradient(colors: [AppColors.primaryBlue, AppColors.secondaryBlue]),
      'titleIcon': Icons.free_breakfast,
    },
    {
      'id': 'premium',
      'title': 'Premium',
      'subtitle': 'Boost your dating game with powerful premium features',
      'price': '\$19.99',
      'priceSuffix': 'per month',
      'features': [
        {'icon': TablerIcons.infinity, 'text': 'Unlimited likes & super likes'},
        {'icon': TablerIcons.eye, 'text': 'See who liked you'},
        {'icon': TablerIcons.arrow_up, 'text': 'Profile boost (2x visibility)'},
        {'icon': TablerIcons.adjustments_horizontal, 'text': 'Advanced matching filters'},
        {'icon': TablerIcons.shield_lock, 'text': 'Browse anonymously'},
        {'icon': TablerIcons.map_pin, 'text': 'Passport (date anywhere)'},
        {'icon': TablerIcons.headset, 'text': 'Priority customer support'},
      ],
      'buttonText': 'GET PREMIUM',
      'isPopular': true,
      'isBestValue': false,
      'cardColor': AppColors.primaryBackground,
      'buttonGradient': const LinearGradient(colors: [AppColors.primaryRed, AppColors.primaryOrange]),
      'titleIcon': Icons.star,
    },
    {
      'id': 'vip',
      'title': 'VIP',
      'subtitle': 'The ultimate dating experience with exclusive VIP perks',
      'price': '\$39.99',
      'priceSuffix': 'per month',
      'features': [
        {'icon': TablerIcons.check, 'text': 'Everything in Premium'},
        {'icon': TablerIcons.bolt, 'text': '5 Super Boosts per month'},
        {'icon': TablerIcons.gift, 'text': 'Send gifts to matches'},
        {'icon': TablerIcons.phone_call, 'text': 'Video & voice calling'},
        {'icon': TablerIcons.mail_opened, 'text': 'Read receipts'},
        {'icon': TablerIcons.crown, 'text': 'VIP badge on profile'},
        {'icon': TablerIcons.vip, 'text': 'Exclusive VIP events'},
        {'icon': TablerIcons.sort_ascending, 'text': 'Priority in match queue'},
      ],
      'buttonText': 'GO VIP',
      'isPopular': false,
      'isBestValue': true,
      'cardColor': AppColors.primaryBackground,
      'buttonGradient': const LinearGradient(colors: [AppColors.primaryRed, AppColors.primaryOrange]),
      'titleIcon': Icons.diamond,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: widget.initialPage,
      viewportFraction: 0.94,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

    // Create dynamic plans based on user's subscription status
    List<Map<String, dynamic>> dynamicPlans = [];
    for (var plan in _plans) {
      Map<String, dynamic> dynamicPlan = Map<String, dynamic>.from(plan);
      
      if (plan['id'] == subscriptionProvider.subscriptionPlan) {
        // This is the user's current plan
        dynamicPlan['buttonText'] = 'Current Plan';
        dynamicPlan['buttonGradient'] = const LinearGradient(colors: [Colors.grey, Colors.grey]);
      } else {
        // Keep original buttonText and gradient
        dynamicPlan['buttonText'] = plan['buttonText'];
        dynamicPlan['buttonGradient'] = plan['buttonGradient'];
      }
      
      dynamicPlans.add(dynamicPlan);
    }

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text('Subscriptions'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Main content area - flexible
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [
                      // Responsive PageView - takes available space
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: dynamicPlans.length,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            final p = dynamicPlans[index];
                            final isActive = index == _currentPage;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                              child: AnimatedScale(
                                scale: isActive ? 1.0 : 0.96,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                                child: SubscriptionCard(
                                  title: p['title'] as String,
                                  subtitle: p['subtitle'] as String,
                                  price: p['price'] as String,
                                  priceSuffix: p['priceSuffix'] as String,
                                  features: List<Map<String, dynamic>>.from(p['features'] as List),
                                  isPopular: p['isPopular'] as bool,
                                  isBestValue: p['isBestValue'] as bool,
                                  cardColor: p['cardColor'] as Color,
                                  buttonGradient: p['buttonGradient'] as LinearGradient?,
                                  titleIcon: p['titleIcon'] as IconData?,
                                  isActive: isActive,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Page indicators
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(dynamicPlans.length, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 6.0),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primaryRed : AppColors.dotInactive,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Bottom fixed area for buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GradientButton(
                      text: dynamicPlans[_currentPage]['buttonText'] as String,
                      gradient: dynamicPlans[_currentPage]['buttonGradient'] as LinearGradient?,
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
                          : (dynamicPlans[_currentPage]['buttonText'] as String) == 'Current Plan'
                              ? null
                              : () {
                                  final planId = dynamicPlans[_currentPage]['id'] as String;
                                  Provider.of<SubscriptionProvider>(
                                    context,
                                    listen: false,
                                  ).purchasePackage(planId).then((success) {
                                    if (success && context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Subscription successful!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    } else if (!success && context.mounted) {
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
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Cancel anytime',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
