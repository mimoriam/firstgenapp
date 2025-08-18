import 'package:firstgenapp/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/onboarding/onboarding_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, String>> _pageData = [
    {
      "backgroundImage": "images/backgrounds/woman_with_phone.png",
      "title": "Celebrate Your Culture",
      "description":
          "Share your heritage and connect with people who appreciate where you come from.",
    },
    {
      "backgroundImage": "images/backgrounds/women_watch_phone.png",
      "title": "Find Shared Stories",
      "description":
          "Meet people who understand your\n journey and embrace cultural connections.",
    },
    {
      "backgroundImage": "images/backgrounds/ratings_bg.svg",
      "foregroundImage": "images/backgrounds/people_bg.png",
      "title": "Join Real Community",
      "description":
          "Thousands of people building\n friendships and celebrating identity-together.",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onContinuePressed() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onSkipPressed() {
    _pageController.jumpToPage(2);
  }

  Future<void> _onLetsGetStartedPressed() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setBool('onboardingDone', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        // MaterialPageRoute(builder: (context) => const SigninScreen()),
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // The onboarding screen is the first thing the user sees,
    // so we can remove the splash screen here.
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor:
            AppColors.secondaryBackground, // Onboarding screen background color
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: constraints.maxHeight * 0.1,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pageData.length,
                    itemBuilder: (context, index) {
                      // If it's the third page (index 2), build the custom layout.
                      if (index == 2) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: constraints.maxHeight * 0.14,
                              child: SvgPicture.asset(
                                _pageData[index]['backgroundImage']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              bottom: constraints.maxHeight * 0.16,
                              width: constraints.maxWidth,
                              height: 200,
                              child: Image.asset(
                                _pageData[index]['foregroundImage']!,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return OnboardingPage(
                          imagePath: _pageData[index]['backgroundImage']!,
                        );
                      }
                    },
                  ),
                ),
                // Position the content card at the bottom.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomCard(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomCard() {
    // UPDATED: Reduced height for a more compact UI
    return Container(
      height: MediaQuery.of(context).size.height * 0.32,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        top: false,
        // UPDATED: Reduced vertical padding
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              // UPDATED: Reduced top spacing
              const SizedBox(height: 20),
              Text(
                _pageData[_currentPage]['title']!,
                textAlign: TextAlign.center,
                // UPDATED: Used new, more appropriate text style from theme
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              // UPDATED: Reduced spacing
              const SizedBox(height: 12),
              Text(
                _pageData[_currentPage]['description']!,
                textAlign: TextAlign.center,
                // UPDATED: Used modified bodySmall from theme for consistency
                style: Theme.of(context).textTheme.bodySmall,
              ),
              // UPDATED: Reduced spacing
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pageData.length,
                  (index) => _buildDot(index: index),
                ),
              ),
              const Spacer(),
              const Divider(color: AppColors.divider, thickness: 0.4),
              // UPDATED: Reduced spacing
              const SizedBox(height: 16),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    if (_currentPage == _pageData.length - 1) {
      return GradientButton(
        text: "Let's Get Started",
        onPressed: _onLetsGetStartedPressed,
        // UPDATED: Reduced font size and padding for a compact button
        fontSize: 14,
        insets: 14,
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _onSkipPressed,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.secondaryBackground,
                // UPDATED: Reduced vertical padding
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Skip',
                // UPDATED: Inherited style from theme and overrode specific properties
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textTertiary.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Reduced font size
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GradientButton(
              text: 'Continue',
              onPressed: _onContinuePressed,
              // UPDATED: Reduced font size and padding for a compact button
              fontSize: 14,
              insets: 14,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primaryRed
            : AppColors.dotInactive,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
