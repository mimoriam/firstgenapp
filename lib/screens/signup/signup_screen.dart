import 'package:firstgenapp/screens/signup/signup2_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  void _onNextPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint("Form is valid. Data: ${_formKey.currentState?.value}");
      if (context.mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const Signup2Screen()));
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            'Begin Your Journey',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create your First Gen account and begin your cultural journey.',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 20),
                          Text('Basic Info', style: textTheme.titleLarge),
                          const SizedBox(height: 16),
                          Text('Full name', style: textTheme.titleMedium),
                          const SizedBox(height: 6),
                          FormBuilderTextField(
                            name: 'full_name',
                            decoration: const InputDecoration(
                              hintText: 'Enter your full name',
                              // UPDATED: Made field more compact
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                // Icons.person_outline,
                                IconlyLight.profile,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            // validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          Text('Email', style: textTheme.titleMedium),
                          const SizedBox(height: 6),
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                              hintText: 'Enter your email',
                              // UPDATED: Made field more compact
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                // Icons.email_outlined,
                                IconlyLight.message,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            // validator: FormBuilderValidators.compose([
                            //   FormBuilderValidators.required(),
                            //   FormBuilderValidators.email(),
                            // ]),
                          ),
                          const SizedBox(height: 16),
                          Text('Password', style: textTheme.titleMedium),
                          const SizedBox(height: 6),
                          FormBuilderTextField(
                            name: 'password',
                            obscureText: _isPasswordObscured,
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              // UPDATED: Made field more compact
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
                                // Icons.lock_outline,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? IconlyLight.hide
                                      : IconlyLight.show,
                                  // ? Icons.visibility_off_outlined
                                  // : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            // validator: FormBuilderValidators.required(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Confirm Password',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          FormBuilderTextField(
                            name: 'confirm_password',
                            obscureText: _isConfirmPasswordObscured,
                            decoration: InputDecoration(
                              hintText: 'Confirm your password',
                              // UPDATED: Made field more compact
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: const Icon(
                                // Icons.lock_outline,
                                IconlyLight.unlock,
                                color: AppColors.textSecondary,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordObscured
                                      ? IconlyLight.hide
                                      : IconlyLight.show,
                                  // ? Icons.visibility_off_outlined
                                  // : Icons.visibility_outlined,
                                  color: AppColors.textSecondary,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordObscured =
                                        !_isConfirmPasswordObscured;
                                  });
                                },
                              ),
                            ),
                            // validator: FormBuilderValidators.compose([
                            //   FormBuilderValidators.required(),
                            //       (val) {
                            //     if (val !=
                            //         _formKey.currentState?.fields['password']
                            //             ?.value) {
                            //       return 'Passwords do not match';
                            //     }
                            //     return null;
                            //   },
                            // ]),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            // fontSize: 14,
                          ),
                          children: const <TextSpan>[
                            TextSpan(
                              text: '1',
                              style: TextStyle(color: AppColors.primaryOrange),
                            ),
                            TextSpan(
                              text: ' out of 10',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryRed,
                              AppColors.primaryOrange,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FloatingActionButton(
                          onPressed: _onNextPressed,
                          elevation: 0,
                          enableFeedback: false,
                          backgroundColor: Colors.transparent,
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
