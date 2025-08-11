import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/auth/signin/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  void _onSavePasswordPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint("Form is valid. New password saved.");
      // TODO: Implement password update logic

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SigninScreen()),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('Create New Password', style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Your new password must be different from your old one.',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 32),
                  Text('New Password', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'password',
                    obscureText: _isPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(
                        IconlyLight.lock,
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
                  const SizedBox(height: 16),
                  Text('Confirm Password', style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FormBuilderTextField(
                    name: 'confirm_password',
                    obscureText: _isConfirmPasswordObscured,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(
                        IconlyLight.lock,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordObscured
                              ? IconlyLight.hide
                              : IconlyLight.show,
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
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      (val) {
                        if (val !=
                            _formKey.currentState?.fields['password']?.value) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ]),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    text: 'Save Password',
                    onPressed: _onSavePasswordPressed,
                    insets: 14,
                    fontSize: 15,
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
