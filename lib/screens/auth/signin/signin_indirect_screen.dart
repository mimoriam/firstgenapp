import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/auth/signin/forgot_password/forgot_password_screen.dart';
import 'package:firstgenapp/screens/auth/signup/signup_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/authException.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class SigninIndirectScreen extends StatefulWidget {
  const SigninIndirectScreen({super.key});

  @override
  State<SigninIndirectScreen> createState() => _SigninIndirectScreenState();
}

class _SigninIndirectScreenState extends State<SigninIndirectScreen> {
  bool _isPasswordObscured = true;
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  // MODIFICATION: Added loading state for Google Sign-In button.
  bool _isGoogleLoading = false;

  Future<void> _onSignInPressed() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final formData = _formKey.currentState?.value;
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      try {
        await firebaseService.loginWithEmail(
          email: formData?["email"],
          password: formData?["password"],
        );

        if (mounted) {
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to sign in: ${e.toString()}"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      debugPrint("Form is invalid");
    }
  }

  // MODIFICATION: Added handler for Google Sign-In.
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;
    setState(() {
      _isGoogleLoading = true;
    });

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await firebaseService.signInWithGoogle();

      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential' &&
          e.credential != null &&
          e.email != null) {
        final password = await _showPasswordDialog();
        if (password != null && password.isNotEmpty) {
          try {
            await firebaseService.linkCredentials(
              email: e.email!,
              password: password,
              credentialToLink: e.credential!,
            );
            // On success, AuthGate will navigate.
          } on AuthException catch (linkError) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text(linkError.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("An unexpected error occurred: ${e.toString()}"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // MODIFICATION: Added dialog to get password for account linking.
  Future<String?> _showPasswordDialog() {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Link Accounts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This Google account uses the same email as an existing account. Please enter your password to link them.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(passwordController.text),
              child: const Text('Link'),
            ),
          ],
        );
      },
    );
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
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                IconlyLight.message,
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
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: const Icon(
                                IconlyLight.unlock,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? IconlyLight.hide
                                      : IconlyLight.show,
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
                          const SizedBox(height: 24),
                          _buildSignUpRedirect(context),
                          const SizedBox(height: 32),
                          _buildDivider(context),
                          const SizedBox(height: 32),
                          _buildSocialLoginRow(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  TapDebouncer(
                    cooldown: const Duration(seconds: 3),
                    onTap: _isLoading ? null : _onSignInPressed,
                    builder: (BuildContext context, TapDebouncerFunc? onTap) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          GradientButton(
                            text: _isLoading ? '' : 'Sign In',
                            onPressed: onTap ?? () {},
                            insets: 14,
                            fontSize: 15,
                          ),
                          if (_isLoading)
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                strokeWidth: 2.0,
                              ),
                            ),
                        ],
                      );
                    },
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
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
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
              fontSize: 13,
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.inputBorder, thickness: 1),
        ),
      ],
    );
  }

  // MODIFICATION: Hooked up Google Sign-In and loading state.
  Widget _buildSocialLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIconButton(
          'images/icons/google.svg',
          _isGoogleLoading ? null : _handleGoogleSignIn,
          isLoading: _isGoogleLoading,
        ),
        // const SizedBox(width: 20),
        // _buildSocialIconButton('images/icons/apple.svg', () {}),
        // const SizedBox(width: 20),
        // _buildSocialIconButton('images/icons/facebook.svg', () {}),
      ],
    );
  }

  // MODIFICATION: Updated to handle loading state.
  Widget _buildSocialIconButton(
    String iconPath,
    VoidCallback? onPressed, {
    bool isLoading = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 17),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            )
          : SvgPicture.asset(iconPath, height: 20, width: 20),
    );
  }
}
