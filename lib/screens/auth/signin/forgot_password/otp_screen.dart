import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/auth/signin/forgot_password/create_new_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement OTP verification logic
      debugPrint('Verifying OTP: ${pinController.text}');
      // On success, navigate to the reset password screen

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CreateNewPasswordScreen()),
        );
      }
    } else {
      debugPrint('Invalid OTP');
    }
  }

  void _onResendPressed() {
    // TODO: Implement resend code logic
    debugPrint('Resend code pressed for ${widget.email}');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: textTheme.headlineSmall?.copyWith(
        fontSize: 22,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
      ),
    );

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Enter Verification Code', style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: textTheme.bodySmall,
                    children: <TextSpan>[
                      const TextSpan(
                        text: 'We have sent a 4-digit verification code to ',
                      ),
                      TextSpan(
                        text: widget.email,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: Center(
                    child: Pinput(
                      length: 4,
                      controller: pinController,
                      focusNode: focusNode,
                      defaultPinTheme: defaultPinTheme,
                      separatorBuilder: (index) => const SizedBox(width: 16),
                      focusedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                      ),
                      submittedPinTheme: defaultPinTheme.copyWith(
                        decoration: defaultPinTheme.decoration!.copyWith(
                          border: Border.all(
                            color: AppColors.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (s) {
                        if (s == null || s.length < 4) {
                          return 'Pin is incomplete';
                        }
                        // TODO: Add real validation logic
                        return null;
                      },
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      showCursor: true,
                      onCompleted: (pin) => debugPrint('Completed: $pin'),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Verify',
                  onPressed: _onVerifyPressed,
                  insets: 14,
                  fontSize: 15,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the code? ",
                      style: textTheme.bodySmall,
                    ),
                    TextButton(
                      onPressed: _onResendPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Resend',
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
