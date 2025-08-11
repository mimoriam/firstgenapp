import 'package:country_flags/country_flags.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/auth/signin/signin_indirect_screen.dart';
import 'package:firstgenapp/screens/auth/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firstgenapp/common/exit_dialog.dart';
import 'package:marqueer/marqueer.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final List<String> _countryCodes = [
    'us', 'ca', 'mx', 'br', 'ar', 'gb', 'fr', 'de', 'it', 'es', 'ru', 'cn',
    'jp', 'in', 'au', 'za', 'ng', 'eg', 'co', 'se', 'il', 'ua', 'no', 'dk',
    'lk', 'sv', 'tz', 'by', 'pk', 'bd', 'vn', 'ph', 'th', 'my', 'id', 'tr',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          showExitConfirmationDialogForHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        _buildLogo(context),
                        const SizedBox(height: 32),
                        _buildWelcomeText(context),
                        const SizedBox(height: 24),
                        _buildSocialButton(
                          context: context,
                          iconPath: 'images/icons/google.svg',
                          text: 'Continue with Google',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildSocialButton(
                          context: context,
                          iconPath: 'images/icons/apple.svg',
                          text: 'Continue with Apple',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 16),
                        _buildSocialButton(
                          context: context,
                          iconPath: 'images/icons/facebook.svg',
                          text: 'Continue with Facebook',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 24),
                        GradientButton(
                          text: 'Sign Up',
                          onPressed: () {
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            }
                          },
                          insets: 14,
                          fontSize: 15,
                        ),
                        const SizedBox(height: 16),
                        _buildSignInButton(context),
                        const SizedBox(height: 24),
                        _buildFooterLinks(context),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildFlagBanner(),
                const SizedBox(height: 32), // UPDATED: Increased bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('images/icons/fg_logo_small.svg', height: 40),
        const SizedBox(width: 12),
        Text(
          'First Gen',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 32,
            color: AppColors.primaryRed,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Welcome to First Gen!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Connecting First Generation Individuals\nand Culture Enthusiasts',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(iconPath, height: 18, width: 18),
            ),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SigninIndirectScreen(),
              ),
            );
          }
        },
        style: TextButton.styleFrom(
          backgroundColor: AppColors.secondaryBackground,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Sign In',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textTertiary.withAlpha(230),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    final footerTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            // TODO: Open Privacy Policy URL
          },
          child: Text('Privacy Policy', style: footerTextStyle),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () {
            // TODO: Open Terms of Service URL
          },
          child: Text('Terms of Services', style: footerTextStyle),
        ),
      ],
    );
  }

  Widget _buildFlagBanner() {
    final List<Widget> flagWidgets = _countryCodes.map((code) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CountryFlag.fromCountryCode(
          code,
          height: 20,
          width: 28,
          shape: const RoundedRectangle(6),
        ),
      );
    }).toList();

    return SizedBox(
      height: 25,
      child: Marqueer(
        pps: 20,
        child: Row(children: flagWidgets),
      ),
    );
  }
}
