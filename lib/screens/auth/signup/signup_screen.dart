import 'dart:async';

import 'package:firstgenapp/screens/auth/signup/signup2_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _arePasswordsObscured = true;
  bool _isLoading = false;
  bool _showBottomNav = true;
  // MODIFICATION: Added state to track SnackBar visibility.
  bool _isSnackBarVisible = false;
  late StreamSubscription<bool> _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    final keyboardVisibilityController = KeyboardVisibilityController();
    _keyboardSubscription = keyboardVisibilityController.onChange.listen((
      bool visible,
    ) {
      if (mounted) {
        if (visible) {
          setState(() {
            _showBottomNav = false;
          });
        } else {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              setState(() {
                _showBottomNav = true;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _keyboardSubscription.cancel();
    super.dispose();
  }

  void _onNextPressed() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      final formData = _formKey.currentState!.value;
      final email = formData['email'];

      final bool emailExists = await firebaseService.checkIfEmailInUse(email);

      if (!mounted) return;

      if (emailExists) {
        _formKey.currentState?.fields['email']?.invalidate(
          'This email address is already in use.',
        );
        // MODIFICATION: Hide bottom bar and show SnackBar.
        setState(() {
          _isSnackBarVisible = true;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(
              const SnackBar(
                content: Text('This email address is already in use.'),
                backgroundColor: AppColors.error,
              ),
            )
            .closed
            .then((_) {
              // MODIFICATION: Show bottom bar again after SnackBar closes.
              if (mounted) {
                setState(() {
                  _isSnackBarVisible = false;
                });
              }
            });
      } else {
        viewModel.updateStep1(
          fullName: formData['full_name'],
          email: email,
          password: formData['password'],
        );

        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const Signup2Screen()));
      }

      setState(() {
        _isLoading = false;
      });
    } else {
      debugPrint("Form is invalid");
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Provider.of<SignUpViewModel>(context, listen: false).reset();
        Navigator.of(context).pop();
      },
      // MODIFICATION: Changed dismissOnCapturedTaps to false.
      child: KeyboardDismissOnTap(
        dismissOnCapturedTaps: false,
        child: Scaffold(
          backgroundColor: AppColors.primaryBackground,
          appBar: AppBar(
            backgroundColor: AppColors.primaryBackground,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                        initialValue: {
                          'full_name': viewModel.fullName,
                          'email': viewModel.email,
                        },
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
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(
                                  IconlyLight.profile,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(3),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            Text('Email', style: textTheme.titleMedium),
                            const SizedBox(height: 6),
                            FormBuilderTextField(
                              name: 'email',
                              decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                contentPadding: EdgeInsets.symmetric(
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
                            const SizedBox(height: 6),
                            FormBuilderTextField(
                              name: 'password',
                              obscureText: _arePasswordsObscured,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
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
                                    _arePasswordsObscured
                                        ? IconlyLight.hide
                                        : IconlyLight.show,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _arePasswordsObscured =
                                        !_arePasswordsObscured,
                                  ),
                                ),
                              ),
                              validator: FormBuilderValidators.compose([
                                FormBuilderValidators.required(),
                                FormBuilderValidators.minLength(
                                  8,
                                  errorText:
                                      'Password must be at least 8 characters long',
                                ),
                              ]),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Confirm Password',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            FormBuilderTextField(
                              name: 'confirm_password',
                              obscureText: _arePasswordsObscured,
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
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
                                    _arePasswordsObscured
                                        ? IconlyLight.hide
                                        : IconlyLight.show,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed: () => setState(
                                    () => _arePasswordsObscured =
                                        !_arePasswordsObscured,
                                  ),
                                ),
                              ),
                              validator: (val) {
                                if (val !=
                                    _formKey
                                        .currentState
                                        ?.fields['password']
                                        ?.value) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 1.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                    child: _showBottomNav && !_isSnackBarVisible
                        ? Padding(
                            key: const ValueKey<int>(1),
                            padding: const EdgeInsets.only(
                              bottom: 12.0,
                              top: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: const <TextSpan>[
                                      TextSpan(
                                        text: '1',
                                        style: TextStyle(
                                          color: AppColors.primaryOrange,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' out of 10',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
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
                                  ),
                                  child: FloatingActionButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _onNextPressed,
                                    elevation: 0,
                                    enableFeedback: false,
                                    backgroundColor: Colors.transparent,
                                    child: _isLoading
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                            strokeWidth: 2.0,
                                          )
                                        : const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey<int>(2)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
