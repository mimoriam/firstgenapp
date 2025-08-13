import 'dart:async';
import 'package:firstgenapp/screens/auth/signup/signup7_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup6Screen extends StatefulWidget {
  const Signup6Screen({super.key});

  @override
  State<Signup6Screen> createState() => _Signup6ScreenState();
}

class _Signup6ScreenState extends State<Signup6Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;

  final List<String> _artOptions = [
    'Traditional dance',
    'Theater & plays',
    'Literature & poetry',
    'Visual arts',
    'International cinema',
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
      ).push(MaterialPageRoute(builder: (context) => const Signup7Screen()));
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
              initialValue: {'music': viewModel.music, 'arts': viewModel.arts},
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
                          Text('Music & Arts', style: textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text(
                            'What music moves your soul?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildMusicInput(),
                          const SizedBox(height: 20),
                          Text(
                            'Cultural arts you enjoy',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          _buildArtChips(),
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

  Widget _buildMusicInput() {
    return FormBuilderTextField(
      name: 'music',
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: 'e.g., Bollywood classics, K-pop etc....',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      validator: FormBuilderValidators.required(
        errorText: 'Please enter your music interests',
      ),
    );
  }

  Widget _buildArtChips() {
    return FormBuilderField<List<String>>(
      name: 'arts',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one art form';
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
              children: _artOptions.map((art) {
                final isSelected = field.value?.contains(art) ?? false;
                return ChoiceChip(
                  label: Text(art),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentSelection = List.from(
                      field.value ?? [],
                    );
                    if (selected) {
                      currentSelection.add(art);
                    } else {
                      currentSelection.remove(art);
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
                          text: '6',
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
