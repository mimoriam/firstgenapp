import 'package:country_picker/country_picker.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';

class ProfileInnerScreen extends StatefulWidget {
  const ProfileInnerScreen({super.key});

  @override
  State<ProfileInnerScreen> createState() => _ProfileInnerScreenState();
}

class _ProfileInnerScreenState extends State<ProfileInnerScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _languageController = TextEditingController();

  final _languagesFieldKey = GlobalKey<FormBuilderFieldState>();

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      debugPrint("Form is valid. Data: ${_formKey.currentState?.value}");
      // TODO: Implement save logic with the form data
      Navigator.of(context).pop();
    } else {
      debugPrint("Form is invalid");
    }
  }

  void _addLanguage() {
    final language = _languageController.text.trim();
    if (language.isNotEmpty) {
      final currentLanguages = List<String>.from(
        _languagesFieldKey.currentState?.value ?? [],
      );
      if (!currentLanguages.contains(language)) {
        currentLanguages.add(language);
        _languagesFieldKey.currentState?.didChange(currentLanguages);
        _languageController.clear();
        FocusScope.of(context).unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
        title: Text(
          'Profile',
          // UPDATED: Inherited from theme
          style: textTheme.titleLarge,
        ),
      ),
      body: KeyboardDismissOnTap(
        dismissOnCapturedTaps: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileAvatar(),
                const SizedBox(height: 24),
                _buildSectionTitle('Full Name', textTheme),
                FormBuilderTextField(
                  name: 'full_name',
                  initialValue: 'Rana Utban',
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    // UPDATED: Compacted field
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      // Icons.person_outline,
                      IconlyLight.profile,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Email', textTheme),
                FormBuilderTextField(
                  name: 'email',
                  initialValue: 'ranautban007@gmail.com',
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    // UPDATED: Compacted field
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      // Icons.email_outlined,
                      IconlyLight.message,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Gender', textTheme),
                _buildGenderChips(),
                const SizedBox(height: 20),
                _buildSectionTitle('Date of birth', textTheme),
                FormBuilderDateTimePicker(
                  name: 'dob',
                  initialValue: DateTime(1995, 12, 25),
                  inputType: InputType.date,
                  format: DateFormat('MM-dd-yyyy'),
                  decoration: const InputDecoration(
                    hintText: 'Select your date of birth',
                    // UPDATED: Compacted field
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    suffixIcon: Icon(
                      // Icons.calendar_today_outlined,
                      IconlyLight.calendar,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('What is your profession?', textTheme),
                FormBuilderTextField(
                  name: 'profession',
                  initialValue: 'Doctor',
                  decoration: const InputDecoration(
                    hintText: 'Enter your profession',
                    // UPDATED: Compacted field
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      // Icons.work_outline,
                      IconlyLight.work,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(
                  'What is your cultural heritage or background?',
                  textTheme,
                ),
                _buildCountryPicker(),
                const SizedBox(height: 20),
                _buildSectionTitle('Language you speak', textTheme),
                _buildLanguageInput(),
                const SizedBox(height: 20),
                _buildSectionTitle('Write a Short Bio', textTheme),
                FormBuilderTextField(
                  name: 'bio',
                  initialValue:
                      'Lorem ipsum dolor sit amet consectetur. Leo nec risus laoreet egestas mauris nulla sagittis odio. Tempor nec congue posuere quam dictum nam mi pulvinar. Sit adipiscing sem et lacus sed eros ac augue.',
                  decoration: const InputDecoration(
                    hintText: 'Tell us about yourself...',
                    // UPDATED: Compacted field
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 5,
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 32),
                GradientButton(
                  text: 'Save',
                  onPressed: _onSavePressed,
                  fontSize: 15,
                  insets: 14,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        // UPDATED: Inherited from theme
        style: textTheme.titleMedium,
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return Center(
      child: Stack(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/75.jpg',
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tertiaryBackground,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(
                  // Icons.edit,
                  IconlyBold.edit,
                  color: AppColors.primaryOrange,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChips() {
    const genders = ['Male', 'Female', 'Other', 'Prefer Not to Say'];
    return FormBuilderField<String>(
      name: 'gender',
      initialValue: 'Male',
      validator: FormBuilderValidators.required(),
      builder: (FormFieldState<String> field) {
        return Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: genders.map((gender) {
            final isSelected = field.value == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) {
                  field.didChange(gender);
                }
              },
              // UPDATED: Compacted chip style
              labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
              ),
              selectedColor: AppColors.secondaryBackground,
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
        );
      },
    );
  }

  Widget _buildCountryPicker() {
    return FormBuilderField<String>(
      name: 'country',
      initialValue: 'UA',
      builder: (FormFieldState<String> field) {
        return InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              countryListTheme: CountryListThemeData(
                bottomSheetHeight: 500,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                inputDecoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Start typing to search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              onSelect: (Country country) {
                field.didChange(country.countryCode);
              },
            );
          },
          child: InputDecorator(
            decoration: InputDecoration(
              // UPDATED: Compacted field
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.inputBorder,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.inputBorder,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  Country.tryParse(field.value ?? 'UA')?.flagEmoji ?? '🇺🇦',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Country.tryParse(field.value ?? 'UA')?.name ?? 'Ukraine',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _languageController,
          decoration: InputDecoration(
            hintText: 'Type a language and press enter',
            // UPDATED: Compacted field
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            prefixIcon: const Icon(
              Icons.translate,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          onSubmitted: (_) => _addLanguage(),
        ),
        const SizedBox(height: 12),
        FormBuilderField<List<String>>(
          key: _languagesFieldKey,
          name: 'languages',
          initialValue: const ['English', 'German'],
          builder: (field) {
            return Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: (field.value ?? []).map((language) {
                return Chip(
                  label: Text(language),
                  onDeleted: () {
                    final currentLanguages = List<String>.from(field.value!);
                    currentLanguages.remove(language);
                    field.didChange(currentLanguages);
                  },
                  deleteIconColor: AppColors.primaryRed,
                  backgroundColor: AppColors.secondaryBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFE9C5C5)),
                  ),
                  // UPDATED: Compacted chip style
                  labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
