import 'dart:io';
import 'package:firstgenapp/screens/signin/signin_indirect_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Signup10Screen extends StatefulWidget {
  const Signup10Screen({super.key});

  @override
  State<Signup10Screen> createState() => _Signup10ScreenState();
}

class _Signup10ScreenState extends State<Signup10Screen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String? _selectedGender;
  bool _termsAccepted = false;
  File? _profileImage;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer Not to Say',
  ];

  @override
  void dispose() {
    _bioController.dispose();
    _dobController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('MM-dd-yyyy').format(picked);
      });
    }
  }

  void _onFinishRegistration() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Terms & Conditions to continue.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    debugPrint("Bio: ${_bioController.text}");
    debugPrint("Gender: $_selectedGender");
    debugPrint("DOB: ${_dobController.text}");
    debugPrint("Profession: ${_professionController.text}");
    debugPrint("Image Path: ${_profileImage?.path}");

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SigninIndirectScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
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
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Begin Your Journey',
                          // UPDATED: Used smaller headline style
                          style: textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create your First Gen account and begin your cultural journey.',
                          // UPDATED: Used smaller body style for consistency
                          style: textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 24),
                        Text(
                          'Profile Setup',
                          // UPDATED: Used new title style
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        _buildImagePicker(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        Text('Write a Short Bio', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _buildBioInput(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        Text('Gender', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _buildGenderChips(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        Text('Date of birth', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _buildDobInput(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        Text(
                          'What is your profession?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildProfessionInput(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 20),
                        _buildTermsAndConditions(),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, top: 10.0),
                  child: GradientButton(
                    text: 'Finish Registration',
                    onPressed: _onFinishRegistration,
                    // UPDATED: Compacted button
                    insets: 14,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        // UPDATED: Increased radius for a larger profile image area
        radius: 70,
        // backgroundColor: AppColors.secondaryBackground,
        backgroundColor: Color(0xFFEEEEEE),
        backgroundImage: _profileImage != null
            ? FileImage(_profileImage!)
            : null,
        child: _profileImage == null
            ? const Icon(
                // Icons.camera_alt_outlined,
                IconlyLight.camera,
                color: AppColors.textSecondary,
                // UPDATED: Increased icon size to match new avatar size
                size: 24,
              )
            : null,
      ),
    );
  }

  Widget _buildBioInput() {
    return TextField(
      controller: _bioController,
      maxLines: 4,
      decoration: const InputDecoration(
        hintText: 'Enter your detail here',
        // UPDATED: Made field more compact
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildGenderChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _genderOptions.map((gender) {
        final isSelected = _selectedGender == gender;
        return ChoiceChip(
          label: Text(gender),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedGender = selected ? gender : null;
            });
          },
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
          ),
          selectedColor: Colors.white,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(
              color: isSelected ? AppColors.primaryRed : AppColors.inputBorder,
              width: 1.5,
            ),
          ),
          showCheckmark: false,
          // UPDATED: Reduced padding for compact chip
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        );
      }).toList(),
    );
  }

  Widget _buildDobInput() {
    return TextField(
      controller: _dobController,
      readOnly: true,
      onTap: _selectDate,
      decoration: const InputDecoration(
        hintText: '12-25-1995',
        // UPDATED: Made field more compact
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        suffixIcon: Icon(
          // Icons.calendar_today_outlined,
          IconlyLight.calendar,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildProfessionInput() {
    return TextField(
      controller: _professionController,
      decoration: const InputDecoration(
        hintText: 'Enter your profession',
        // UPDATED: Made field more compact
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        prefixIcon: Icon(
          // Icons.work_outline,
          IconlyLight.work,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    final baseStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final linkStyle = baseStyle?.copyWith(
      color: AppColors.primaryRed,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    // UPDATED: Wrapped in Transform.translate to align checkbox to the left
    return Transform.translate(
      offset: const Offset(-11, -10),
      child: Row(
        children: [
          Checkbox(
            value: _termsAccepted,
            onChanged: (bool? value) {
              setState(() {
                _termsAccepted = value ?? false;
              });
            },
            activeColor: AppColors.primaryRed,
            side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
            // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: baseStyle,
                children: [
                  const TextSpan(text: 'Accept '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        debugPrint('Navigate to T&C');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
