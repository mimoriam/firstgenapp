import 'package:firstgenapp/screens/auth/signup/signup4_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';

class Signup3Screen extends StatefulWidget {
  const Signup3Screen({super.key});

  @override
  State<Signup3Screen> createState() => _Signup3ScreenState();
}

class _Signup3ScreenState extends State<Signup3Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  final List<String> _religionOptions = [
    'Christianity',
    'Islam',
    'Hinduism',
    'Buddhism',
    'Judaism',
    'Spiritual',
    'Agnostic',
    'Atheist',
    'Other',
  ];

  void _onNextPressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      final viewModel = Provider.of<SignUpViewModel>(context, listen: false);
      viewModel.updateData(_formKey.currentState!.value);
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup4Screen()));
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

    return Scaffold(
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
              'religion': viewModel.religion,
              'religion_importance': viewModel.religionImportance,
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
                          'Religion & Spirituality',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'What is your religion or spiritual background?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildReligionChips(),
                        const SizedBox(height: 20),
                        Text(
                          'How important is sharing similar spiritual beliefs with a partner?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildImportanceSlider(),
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
    );
  }

  Widget _buildReligionChips() {
    return FormBuilderField<String>(
      name: 'religion',
      validator: FormBuilderValidators.required(
        errorText: 'Please select your religion',
      ),
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _religionOptions.map((religion) {
                final isSelected = field.value == religion;
                return ChoiceChip(
                  label: Text(religion),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      field.didChange(religion);
                    }
                  },
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppColors.primaryRed
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  selectedColor: AppColors.secondaryBackground,
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

  Widget _buildImportanceSlider() {
    return FormBuilderSlider(
      name: 'religion_importance',
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

  Widget _buildBottomNav(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                  text: '3',
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    )
                  : const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
