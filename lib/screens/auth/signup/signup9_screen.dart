import 'dart:async';
import 'package:firstgenapp/screens/auth/signup/signup10_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup9Screen extends StatefulWidget {
  const Signup9Screen({super.key});

  @override
  State<Signup9Screen> createState() => _Signup9ScreenState();
}

class _Signup9ScreenState extends State<Signup9Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;

  final List<String> _relationshipOptions = [
    'Friendship',
    'Networking',
    'Dating',
    'Cultural Exchange',
    'Community Support',
    'Not Sure Yet',
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
      ).push(MaterialPageRoute(builder: (context) => const Signup10Screen()));
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: FormBuilder(
              key: _formKey,
              initialValue: {
                'relationship_seeking': viewModel.relationshipSeeking,
                'partner_cultural_background_importance':
                    viewModel.partnerCulturalBackgroundImportance,
                'deal_breakers': viewModel.dealBreakers,
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
                            'What you are Looking For',
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'What kind of relationship are you seeking?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _buildRelationshipChips(),
                          const SizedBox(height: 20),
                          Text(
                            'How important is that your partner shares your cultural background?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _buildImportanceSlider(),
                          const SizedBox(height: 20),
                          Text(
                            'What are your absolute deal-breakers?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _buildDealBreakerInput(),
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

  Widget _buildRelationshipChips() {
    return FormBuilderField<String>(
      name: 'relationship_seeking',
      validator: FormBuilderValidators.required(
        errorText: 'Please select what you are looking for',
      ),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 5.0,
              runSpacing: 10.0,
              children: _relationshipOptions.map((relationship) {
                final isSelected = field.value == relationship;
                return ChoiceChip(
                  label: Text(relationship),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      field.didChange(relationship);
                    }
                  },
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
                    horizontal: 14.0,
                    vertical: 8.0,
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

  Widget _buildImportanceSlider() {
    return FormBuilderSlider(
      name: 'partner_cultural_background_importance',
      min: 0.0,
      max: 1.0,
      initialValue: 0.5,
      divisions: 4,
      displayValues: DisplayValues.current,
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      activeColor: AppColors.primaryRed,
      inactiveColor: AppColors.inputBorder,
    );
  }

  Widget _buildDealBreakerInput() {
    return FormBuilderTextField(
      name: 'deal_breakers',
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'e.g, smoking, dishonesty, lack of family respect....',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please enter your deal-breakers',
      ),
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
              padding: const EdgeInsets.only(top: 10.0, bottom: 12.0, left: 10),
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
                          text: '9',
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
