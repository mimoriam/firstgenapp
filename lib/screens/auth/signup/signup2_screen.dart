import 'package:firstgenapp/screens/auth/signup/signup3_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class Signup2Screen extends StatefulWidget {
  const Signup2Screen({super.key});

  @override
  State<Signup2Screen> createState() => _Signup2ScreenState();
}

class _Signup2ScreenState extends State<Signup2Screen> {
  final TextEditingController _languageController = TextEditingController();

  Country? _selectedCountry;
  final List<String> _languages = ['English', 'German'];
  String? _selectedGeneration;

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
    _selectedCountry = Country.parse('UA');
  }

  @override
  void dispose() {
    _languageController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    debugPrint("Selected Country: ${_selectedCountry?.name}");
    debugPrint("Languages: $_languages");
    debugPrint("Generation: $_selectedGeneration");

    if (context.mounted) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const Signup3Screen()));
    }
  }

  void _addLanguage() {
    final language = _languageController.text.trim();
    if (language.isNotEmpty && !_languages.contains(language)) {
      setState(() {
        _languages.add(language);
        _languageController.clear();
      });
      FocusScope.of(context).unfocus();
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
                        const SizedBox(height: 16),
                        Text(
                          'Cultural Background',
                          // UPDATED: Used new title style
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'What is your cultural heritage or background?',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        _buildCountryPicker(context),
                        // UPDATED: Reduced spacing
                        const SizedBox(height: 12),
                        Text('Language you speak', style: textTheme.titleMedium),
                        const SizedBox(height: 8),
                        _buildLanguageInput(),
                        const SizedBox(height: 10),
                        _buildLanguageChips(),
                        // UPDATED: Reduced spacing
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
    );
  }

  Widget _buildCountryPicker(BuildContext context) {
    return GestureDetector(
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
            setState(() {
              _selectedCountry = country;
            });
          },
        );
      },
      child: Container(
        // UPDATED: Reduced vertical padding for compact feel
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inputBorder, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.inputFill,
        ),
        child: Row(
          children: [
            if (_selectedCountry != null) ...[
              Text(
                _selectedCountry!.flagEmoji,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(width: 12),
              Text(
                _selectedCountry!.name,
                // UPDATED: Inherited from theme and reduced font size
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageInput() {
    return TextField(
      controller: _languageController,
      decoration: const InputDecoration(
        hintText: 'Type your language',
        // UPDATED: Reduced hint size and padding for compactness
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        prefixIcon: Icon(Icons.translate, color: AppColors.textSecondary),
      ),
      onSubmitted: (_) => _addLanguage(),
    );
  }

  Widget _buildLanguageChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _languages.map((language) {
        return Chip(
          label: Text(language),
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryRed),
          backgroundColor: AppColors.secondaryBackground,
          onDeleted: () {
            setState(() {
              _languages.remove(language);
            });
          },
          deleteIcon: const Icon(Icons.close, size: 16),
          deleteIconColor: AppColors.primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(color: Color(0xFFE9C5C5)),
          ),
          // UPDATED: Reduced padding for compact chip
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        );
      }).toList(),
    );
  }

  Widget _buildGenerationChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _generationOptions.map((generation) {
        final isSelected = _selectedGeneration == generation;
        return ChoiceChip(
          label: Text(generation),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedGeneration = selected ? generation : null;
            });
          },
          // UPDATED: Reduced font size for compact chip
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
          selectedColor: AppColors.primaryRed,
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

  Widget _buildBottomNav(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 24.0),
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: _onNextPressed,
              elevation: 0,
              enableFeedback: false,
              backgroundColor: Colors.transparent,
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}