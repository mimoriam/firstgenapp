import 'dart:async';
import 'package:firstgenapp/screens/auth/signup/signup3_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup2Screen extends StatefulWidget {
  const Signup2Screen({super.key});

  @override
  State<Signup2Screen> createState() => _Signup2ScreenState();
}

class _Signup2ScreenState extends State<Signup2Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _languageController = TextEditingController();
  bool _isLoading = false;
  bool _showBottomNav = true;
  late StreamSubscription<bool> _keyboardSubscription;

  final List<String> _generationOptions = [
    'First generation',
    'Second generation',
    'Culture enthusiast',
    'Mixed heritage',
    'Not sure',
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
    _languageController.dispose();
    _keyboardSubscription.cancel();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      final formData = _formKey.currentState!.value;
      viewModel.updateData(formData);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup3Screen()));
      setState(() {
        _isLoading = false;
      });
    } else {
      debugPrint("Form is invalid");
    }
  }

  void _addLanguage() {
    final language = _languageController.text.trim();
    if (language.isNotEmpty) {
      final currentLanguages = List<String>.from(
        _formKey.currentState?.fields['languages']?.value ?? [],
      );
      if (!currentLanguages.contains(language)) {
        currentLanguages.add(language);
        _formKey.currentState?.fields['languages']?.didChange(currentLanguages);
        _languageController.clear();
        FocusScope.of(context).unfocus();
      }
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
                // MODIFICATION: Set default value for cultural_heritage to 'US'.
                'cultural_heritage': viewModel.culturalHeritage ?? 'US',
                'languages': viewModel.languages.isNotEmpty
                    ? viewModel.languages
                    : ['English'],
                'generation': viewModel.generation,
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
                          const SizedBox(height: 16),
                          Text(
                            'Cultural Background',
                            style: textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'What is your cultural heritage or background?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildCountryPicker(),
                          const SizedBox(height: 12),
                          Text(
                            'Language you speak',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _buildLanguageInput(),
                          const SizedBox(height: 10),
                          _buildLanguageChips(),
                          const SizedBox(height: 12),
                          Text(
                            'Which generation are you?',
                            style: textTheme.titleMedium,
                          ),
                          const SizedBox(height: 10),
                          _buildGenerationChips(),
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

  Widget _buildCountryPicker() {
    return FormBuilderField<String>(
      name: 'cultural_heritage',
      validator: FormBuilderValidators.required(
        errorText: 'Please select your heritage',
      ),
      builder: (FormFieldState<String> field) {
        return InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: false,
              countryListTheme: CountryListThemeData(
                bottomSheetHeight: 550,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                inputDecoration: InputDecoration(
                  hintText: 'Search your heritage',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                ),
              ),
              onSelect: (Country country) {
                field.didChange(country.countryCode);
              },
            );
          },
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.inputBorder,
                  width: 1.5,
                ),
              ),
              errorText: field.errorText,
            ),
            child: Row(
              children: [
                Text(
                  Country.tryParse(field.value ?? 'US')?.flagEmoji ?? '🇺🇸',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Country.tryParse(field.value ?? 'US')?.name ??
                        'United States',
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageInput() {
    return TextField(
      controller: _languageController,
      decoration: const InputDecoration(
        hintText: 'Type your language',
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: Icon(Icons.translate, color: AppColors.textSecondary),
      ),
      onSubmitted: (_) => _addLanguage(),
    );
  }

  Widget _buildLanguageChips() {
    return FormBuilderField<List<String>>(
      name: 'languages',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please add at least one language';
        }
        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: (field.value ?? []).map((language) {
                return Chip(
                  label: Text(language),
                  labelStyle: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.primaryRed),
                  backgroundColor: AppColors.secondaryBackground,
                  onDeleted: () {
                    final currentLanguages = List<String>.from(field.value!);
                    currentLanguages.remove(language);
                    field.didChange(currentLanguages);
                  },
                  deleteIcon: const Icon(Icons.close, size: 16),
                  deleteIconColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    side: const BorderSide(color: Color(0xFFE9C5C5)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
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

  Widget _buildGenerationChips() {
    return FormBuilderField<String>(
      name: 'generation',
      validator: FormBuilderValidators.required(
        errorText: 'Please select a generation status',
      ),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _generationOptions.map((generation) {
                final isSelected = field.value == generation;
                return ChoiceChip(
                  label: Text(generation),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      field.didChange(generation);
                    }
                  },
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  selectedColor: AppColors.primaryRed,
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
                          text: '2',
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
