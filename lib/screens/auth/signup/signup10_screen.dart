import 'dart:async';
import 'dart:io';
import 'package:firstgenapp/auth_gate.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:firstgenapp/viewmodels/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class Signup10Screen extends StatefulWidget {
  const Signup10Screen({super.key});

  @override
  State<Signup10Screen> createState() => _Signup10ScreenState();
}

class _Signup10ScreenState extends State<Signup10Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;
  bool _isLoading = false;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer Not to Say',
  ];

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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image != null) {
      _formKey.currentState?.fields['profile_image']?.didChange(
        File(image.path),
      );
    }
  }

  void _onFinishRegistration(SignUpViewModel viewModel) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final formData = _formKey.currentState!.value;
      viewModel.updateData(formData);

      try {
        await viewModel.completeRegistration();
        if (mounted) {
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).recheckUserProfile();

          viewModel.reset();
          // FIX: Navigate directly to DashboardScreen instead of AuthGate.
          // This ensures the user lands on the correct screen and
          // rebuilds the navigation stack properly.
          // Navigator.of(context).pushAndRemoveUntil(
          //   MaterialPageRoute(builder: (context) => const DashboardScreen()),
          //   (Route<dynamic> route) => false,
          // );
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Registration failed: ${e.toString()}"),
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = context.watch<SignUpViewModel>();

    // MODIFICATION: Changed dismissOnCapturedTaps to false.
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'profile_image': viewModel.profileImage,
                'bio': viewModel.bio,
                'gender': viewModel.gender,
                'dob': viewModel.dateOfBirth,
                'profession': viewModel.profession,
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Final Step!', style: textTheme.headlineSmall),
                          const SizedBox(height: 6),
                          Text(
                            'Complete your profile to join the community.',
                            style: textTheme.bodySmall,
                          ),
                          const SizedBox(height: 24),
                          Text('Profile Setup', style: textTheme.titleLarge),
                          const SizedBox(height: 20),
                          _buildImagePicker(),
                          const SizedBox(height: 20),
                          Text(
                            'Write a Short Bio',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildBioInput(),
                          const SizedBox(height: 20),
                          Text('Gender', style: textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _buildGenderChips(),
                          const SizedBox(height: 20),
                          Text('Date of birth', style: textTheme.titleMedium),
                          const SizedBox(height: 12),
                          _buildDobInput(),
                          const SizedBox(height: 20),
                          Text(
                            'What is your profession?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildProfessionInput(),
                          // MODIFICATION: Reduced top and bottom padding.
                          // const SizedBox(height: 10),
                          _buildTermsAndConditions(),
                          // const SizedBox(height: 10),
                        ],
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
                    child: _showBottomNav
                        ? Padding(
                            key: const ValueKey<int>(1),
                            padding: const EdgeInsets.only(
                              bottom: 24.0,
                              top: 10.0,
                            ),
                            child: TapDebouncer(
                              cooldown: const Duration(seconds: 3),
                              onTap: _isLoading
                                  ? null
                                  : () async =>
                                        _onFinishRegistration(viewModel),
                              builder:
                                  (
                                    BuildContext context,
                                    TapDebouncerFunc? onTap,
                                  ) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        GradientButton(
                                          text: _isLoading
                                              ? ''
                                              : 'Finish Registration',
                                          onPressed: onTap ?? () {},
                                          insets: 14,
                                          fontSize: 15,
                                        ),
                                        if (_isLoading)
                                          const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                              strokeWidth: 2.0,
                                            ),
                                          ),
                                      ],
                                    );
                                  },
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

  Widget _buildImagePicker() {
    return FormBuilderField<File>(
      name: 'profile_image',
      validator: FormBuilderValidators.required(
        errorText: 'Please upload a profile picture.',
      ),
      builder: (FormFieldState<File> field) {
        return GestureDetector(
          onTap: _pickImage,
          child: Row(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: const Color(0xFFEEEEEE),
                backgroundImage: field.value != null
                    ? FileImage(field.value!)
                    : null,
                child: field.value == null
                    ? const Icon(
                        IconlyLight.camera,
                        color: AppColors.textSecondary,
                        size: 24,
                      )
                    : null,
              ),
              if (field.hasError)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBioInput() {
    return FormBuilderTextField(
      name: 'bio',
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Enter your detail here',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        alignLabelWithHint: true,
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please write a short bio',
      ),
    );
  }

  Widget _buildGenderChips() {
    return FormBuilderField<String>(
      name: 'gender',
      validator: FormBuilderValidators.required(
        errorText: 'Please select a gender',
      ),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _genderOptions.map((gender) {
                final isSelected = field.value == gender;
                return ChoiceChip(
                  label: Text(gender),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      field.didChange(gender);
                    }
                  },
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.textSecondary,
                  ),
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryRed
                          : AppColors.inputBorder,
                      width: 1.5,
                    ),
                  ),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                );
              }).toList(),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDobInput() {
    return FormBuilderDateTimePicker(
      name: 'dob',
      inputType: InputType.date,
      format: DateFormat('MM-dd-yyyy'),
      decoration: const InputDecoration(
        hintText: '12-25-1995',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        suffixIcon: Icon(IconlyLight.calendar, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please select your date of birth',
      ),
    );
  }

  Widget _buildProfessionInput() {
    return FormBuilderTextField(
      name: 'profession',
      decoration: const InputDecoration(
        hintText: 'Enter your profession',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: Icon(IconlyLight.work, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please enter your profession',
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final linkStyle = baseStyle?.copyWith(
      color: AppColors.primaryRed,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    return Transform.translate(
      offset: const Offset(-18, 0),
      child: FormBuilderCheckbox(
        name: 'terms_accepted',
        initialValue: false,
        contentPadding: EdgeInsets.zero,
        title: RichText(
          text: TextSpan(
            style: baseStyle,
            children: [
              const TextSpan(text: 'Accept '),
              TextSpan(
                text: 'Terms & Conditions',
                style: linkStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () => debugPrint('Navigate to T&C'),
              ),
            ],
          ),
        ),
        validator: FormBuilderValidators.equal(
          true,
          errorText: 'You must accept the terms and conditions',
        ),
      ),
    );
  }
}
