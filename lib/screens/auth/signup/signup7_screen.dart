import 'package:firstgenapp/screens/auth/signup/signup8_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class Signup7Screen extends StatefulWidget {
  const Signup7Screen({super.key});

  @override
  State<Signup7Screen> createState() => _Signup7ScreenState();
}

class _Signup7ScreenState extends State<Signup7Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  final List<String> _valueOptions = [
    'Family first',
    'Education & growth',
    'Community service',
    'Honesty & integrity',
    'Hard work & ambition',
    'Respect for elders',
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
      ).push(MaterialPageRoute(builder: (context) => const Signup8Screen()));
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
            initialValue: {'core_values': viewModel.coreValues},
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
                        Text('Values & Beliefs', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                        Text(
                          'What are your core values? (Select your top 3)',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildValueChips(),
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

  Widget _buildValueChips() {
    return FormBuilderField<List<String>>(
      name: 'core_values',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one value';
        }
        if (value.length > 3) {
          return 'Please select no more than 3 values';
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
              children: _valueOptions.map((value) {
                final isSelected = field.value?.contains(value) ?? false;
                return ChoiceChip(
                  label: Text(value),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentSelection = List.from(
                      field.value ?? [],
                    );
                    if (selected) {
                      if (currentSelection.length < 3) {
                        currentSelection.add(value);
                      }
                    } else {
                      currentSelection.remove(value);
                    }
                    field.didChange(currentSelection);
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
                  text: '7',
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
