import 'package:firstgenapp/screens/auth/signup/signup5_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';

class Signup4Screen extends StatefulWidget {
  const Signup4Screen({super.key});

  @override
  State<Signup4Screen> createState() => _Signup4ScreenState();
}

class _Signup4ScreenState extends State<Signup4Screen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  final List<String> _traditionOptions = [
    'Cultural holiday',
    'Food traditions',
    'Religious practice',
    'Music & dance',
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
      ).push(MaterialPageRoute(builder: (context) => const Signup5Screen()));
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
              'family_importance': viewModel.familyImportance,
              'traditions': viewModel.traditions,
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
                          'Family & Traditions',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'How important is family in your life?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildFamilySlider(),
                        const SizedBox(height: 20),
                        Text(
                          'Which traditions are important to you?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildTraditionChips(),
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

  Widget _buildFamilySlider() {
    return FormBuilderSlider(
      name: 'family_importance',
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

  Widget _buildTraditionChips() {
    return FormBuilderField<List<String>>(
      name: 'traditions',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select at least one tradition';
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
              children: _traditionOptions.map((tradition) {
                final isSelected = field.value?.contains(tradition) ?? false;
                return ChoiceChip(
                  label: Text(tradition),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentSelection = List.from(
                      field.value ?? [],
                    );
                    if (selected) {
                      currentSelection.add(tradition);
                    } else {
                      currentSelection.remove(tradition);
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
                  text: '4',
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
