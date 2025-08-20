import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class ProfileInnerScreen extends StatefulWidget {
  const ProfileInnerScreen({super.key});

  @override
  State<ProfileInnerScreen> createState() => _ProfileInnerScreenState();
}

class _ProfileInnerScreenState extends State<ProfileInnerScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _languageController = TextEditingController();
  final _languagesFieldKey = GlobalKey<FormBuilderFieldState>();

  User? _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    _user = firebaseService.currentUser;
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final formData = _formKey.currentState!.value;

      final Map<String, dynamic> dataToUpdate = {
        'fullName': formData['full_name'],
        'gender': formData['gender'],
        'dateOfBirth': formData['dob'],
        'profession': formData['profession'],
        'culturalHeritage': formData['country'],
        'languages': formData['languages'],
        'bio': formData['bio'],
      };

      try {
        await firebaseService.updateUserProfile(dataToUpdate);

        // Refresh the centralized user profile data.
        await Provider.of<UserProfileViewModel>(
          context,
          listen: false,
        ).refreshUserProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: UniqueKey(),
              duration: const Duration(milliseconds: 500),
              content: const Text("Profile updated successfully!"),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              key: UniqueKey(),
              content: Text("Failed to update profile: ${e.toString()}"),
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
        title: Text('Profile', style: textTheme.titleLarge),
      ),
      body: Consumer<UserProfileViewModel>(
        builder: (context, userProfileViewModel, child) {
          if (userProfileViewModel.isLoading ||
              userProfileViewModel.userProfileData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userProfileViewModel.userProfileData;
          final dob = (userData?['dateOfBirth'] as Timestamp?)?.toDate();

          return KeyboardDismissOnTap(
            dismissOnCapturedTaps: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: FormBuilder(
                key: _formKey,
                initialValue: {
                  'full_name': userData?['fullName'] ?? _user?.displayName,
                  'email': userData?['email'] ?? _user?.email,
                  'gender': userData?['gender'],
                  'dob': dob,
                  'profession': userData?['profession'],
                  'country': userData?['culturalHeritage'],
                  'languages': List<String>.from(userData?['languages'] ?? []),
                  'bio': userData?['bio'],
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Full Name', textTheme),
                    FormBuilderTextField(
                      name: 'full_name',
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
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
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
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
                      inputType: InputType.date,
                      format: DateFormat('MM-dd-yyyy'),
                      decoration: const InputDecoration(
                        hintText: 'Select your date of birth',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        suffixIcon: Icon(
                          IconlyLight.calendar,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle('What is your profession?', textTheme),
                    FormBuilderTextField(
                      name: 'profession',
                      decoration: const InputDecoration(
                        hintText: 'Enter your profession',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(
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
                      decoration: const InputDecoration(
                        hintText: 'Tell us about yourself...',
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
                    TapDebouncer(
                      cooldown: const Duration(seconds: 3),
                      onTap: _isLoading ? null : _onSavePressed,
                      builder: (BuildContext context, TapDebouncerFunc? onTap) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            GradientButton(
                              text: _isLoading ? '' : 'Save',
                              onPressed: () {
                                if (onTap != null) {
                                  onTap();
                                }
                              },
                              fontSize: 15,
                              insets: 14,
                            ),
                            if (_isLoading)
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2.0,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: textTheme.titleMedium),
    );
  }

  Widget _buildProfileAvatar() {
    final hasPhoto = _user?.photoURL != null && _user!.photoURL!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.secondaryBackground,
            backgroundImage: hasPhoto ? NetworkImage(_user!.photoURL!) : null,
            child: !hasPhoto
                ? const Icon(
                    IconlyLight.profile,
                    size: 50,
                    color: AppColors.textSecondary,
                  )
                : null,
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
                  Country.tryParse(field.value ?? 'US')?.flagEmoji ?? '🇺🇸',
                  style: const TextStyle(fontSize: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Country.tryParse(field.value ?? 'US')?.name ??
                        'United States',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
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
          decoration: const InputDecoration(
            hintText: 'Type a language and press enter',
            hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            prefixIcon: Icon(
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please add at least one language.';
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
                      onDeleted: () {
                        final currentLanguages = List<String>.from(
                          field.value!,
                        );
                        currentLanguages.remove(language);
                        field.didChange(currentLanguages);
                      },
                      deleteIconColor: AppColors.primaryRed,
                      backgroundColor: AppColors.secondaryBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFE9C5C5)),
                      ),
                      labelStyle: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
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
        ),
      ],
    );
  }
}
