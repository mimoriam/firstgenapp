import 'dart:async';
import 'package:firstgenapp/screens/auth/signup/signup9_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup8Screen extends StatefulWidget {
  const Signup8Screen({super.key});

  @override
  State<Signup8Screen> createState() => _Signup8ScreenState();
}

class _Signup8ScreenState extends State<Signup8Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;

  final List<String> _sportOptions = [
    'Soccer/football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Martial arts',
    'Other',
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

  void _onNextPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.updateData(_formKey.currentState!.value);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup9Screen()));
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
                'hobbies': viewModel.hobbies,
                'sports': viewModel.sports,
              },
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Begin Your Journey',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create your First Gen account and begin your cultural journey.',
                            style: textTheme.bodySmall?.copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Hobbies & Interest',
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'What do you love to do in your free time?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildHobbiesInput(),
                          const SizedBox(height: 20),
                          Text(
                            'Sports & activates you enjoy',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildSportChips(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(textTheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHobbiesInput() {
    return FormBuilderTextField(
      name: 'hobbies',
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: 'Tell us about your passions, hobbies, and interest...',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please enter your hobbies',
      ),
    );
  }

  Widget _buildSportChips() {
    return FormBuilderField<List<String>>(
      name: 'sports',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one sport';
        }
        return null;
      },
      builder: (FormFieldState<List<String>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _sportOptions.map((sport) {
                final isSelected = field.value?.contains(sport) ?? false;
                return ChoiceChip(
                  label: Text(sport),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentSelection = List.from(
                      field.value ?? [],
                    );
                    if (selected) {
                      currentSelection.add(sport);
                    } else {
                      currentSelection.remove(sport);
                    }
                    field.didChange(currentSelection);
                  },
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.textSecondary,
                  ),
                  selectedColor: Colors.white,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
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

  Widget _buildBottomNav(TextTheme textTheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      transitionBuilder: (Widget child, Animation<double> animation) {
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
              padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
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
                          text: '8',
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
                        colors: [AppColors.primaryRed, AppColors.primaryOrange],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: FloatingActionButton(
                      onPressed: _isLoading ? null : _onNextPressed,
                      elevation: 0,
                      enableFeedback: false,
                      backgroundColor: Colors.transparent,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
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
    );
  }
}
