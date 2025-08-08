import 'package:firstgenapp/screens/dashboard/dashboard_screen.dart';
import 'package:firstgenapp/screens/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class SigninIndirectScreen extends StatefulWidget {
  const SigninIndirectScreen({super.key});

  @override
  State<SigninIndirectScreen> createState() => _SigninIndirectScreenState();
}

class _SigninIndirectScreenState extends State<SigninIndirectScreen> {
  bool _isPasswordObscured = true;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _rememberMe = false;

  void _onSignInPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      debugPrint("Form is valid. Data: $formData");
      debugPrint("Remember Me is checked: $_rememberMe");

      // TODO: Implement Sign In Logic with formData and _rememberMe value

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } else {
      debugPrint("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text('Welcome Back', style: textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text(
                            'Access your First Gen account and reconnect with your community.',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          Text('Email', style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          const SizedBox(height: 16),
                          Text('Password', style: textTheme.titleMedium),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: 'password',
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 6),
                          _buildRememberAndForgotRow(context),
                          const SizedBox(height: 16),
                          _buildSignUpRedirect(context),
                          const SizedBox(height: 16),
                          _buildDivider(context),
                          const SizedBox(height: 16),
                          _buildSocialLoginRow(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  GradientButton(
                    text: 'Sign In',
                    onPressed: _onSignInPressed,
                    insets: 14,
                    fontSize: 15,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRememberAndForgotRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // UPDATED: Wrapped in Transform.translate to perfectly align the checkbox
        Transform.translate(
          offset: const Offset(-10, 0),
          child: Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppColors.primaryRed,
                side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
                // UPDATED: Reduced tap area to help with alignment
                // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                  });
                },
                child: Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // TODO: Navigate to Forgot Password screen
          },
          // UPDATED: Removed padding to ensure right alignment
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Forgot Password',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpRedirect(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TextButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              );
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Sign up',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.inputBorder, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            'or continue with',
            style: Theme.of(
              context,
            ).textTheme.bodySmall,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.inputBorder, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIconButton('images/icons/google.svg', () {}),
        const SizedBox(width: 20),
        _buildSocialIconButton('images/icons/apple.svg', () {}),
        const SizedBox(width: 20),
        _buildSocialIconButton('images/icons/facebook.svg', () {}),
      ],
    );
  }

  Widget _buildSocialIconButton(String iconPath, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      ),
      child: SvgPicture.asset(iconPath, height: 24, width: 24),
    );
  }
}