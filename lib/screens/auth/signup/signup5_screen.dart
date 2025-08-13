import 'dart:async';
import 'package:firstgenapp/screens/auth/signup/signup6_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup5Screen extends StatefulWidget {
  const Signup5Screen({super.key});

  @override
  State<Signup5Screen> createState() => _Signup5ScreenState();
}

class _Signup5ScreenState extends State<Signup5Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;

  final List<String> _dietOptions = [
    'Vegetarian',
    'Vegan',
    'Kosher',
    'Halal',
    'No restrictions',
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
      ).push(MaterialPageRoute(builder: (context) => const Signup6Screen()));
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
                'cuisines': viewModel.cuisines,
                'dietary_preferences': viewModel.dietaryPreferences,
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
                          Text('Food & Lifestyle', style: textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text(
                            'What cuisines do you love?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildCuisineInput(),
                          const SizedBox(height: 20),
                          Text(
                            'Dietary preferences/restrictions',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildDietChips(),
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

  Widget _buildCuisineInput() {
    return FormBuilderTextField(
      name: 'cuisines',
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: 'e.g., authentic Mexican food, Korean BBQ etc....',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please enter your favorite cuisines',
      ),
    );
  }

  Widget _buildDietChips() {
    return FormBuilderField<List<String>>(
      name: 'dietary_preferences',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one dietary preference';
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
              children: _dietOptions.map((diet) {
                final isSelected = field.value?.contains(diet) ?? false;
                return ChoiceChip(
                  label: Text(diet),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentSelection = List.from(
                      field.value ?? [],
                    );
                    if (selected) {
                      currentSelection.add(diet);
                    } else {
                      currentSelection.remove(diet);
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
                          text: '5',
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
