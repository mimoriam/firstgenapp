import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _selectedCountry = 'UA'; // Default to Ukraine
  RangeValues _currentRangeValues = const RangeValues(25, 30);

  // Controllers for text fields
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  // Lists to hold the chip data
  final List<String> _languages = ['English', 'German'];
  final List<String> _professions = ['Doctor', 'Engineer'];
  final List<String> _interests = ['Reading', 'Coffee'];

  String? _selectedGeneration;
  String? _selectedGender;

  final List<String> _generationOptions = [
    'First generation',
    'Second generation',
    'Culture enthusiast',
    'Mixed heritage',
    'Not sure',
  ];
  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer Not to Say',
  ];

  late StreamSubscription<bool> keyboardSubscription;

  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription = keyboardVisibilityController.onChange.listen((
        bool visible,
        ) {
      setState(() {
        _isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    _languageController.dispose();
    _professionController.dispose();
    _interestController.dispose();
    keyboardSubscription.cancel();
    super.dispose();
  }

  void _addItemToList(
      String item,
      List<String> list,
      TextEditingController controller,
      ) {
    final trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty && !list.contains(trimmedItem)) {
      setState(() {
        list.add(trimmedItem);
        controller.clear();
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
          title: const Text("Who's Out There?"),
          titleTextStyle: textTheme.headlineSmall,
          backgroundColor: AppColors.primaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(20.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Let's find someone you'd love to connect with.",
                  style: textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Country of origin', textTheme),
                _buildCountryPicker(),
                const SizedBox(height: 20),
                _TitledChipInput(
                  title: 'Language',
                  hint: 'Type specific language',
                  items: _languages,
                  controller: _languageController,
                  onSubmitted: () => _addItemToList(
                    _languageController.text,
                    _languages,
                    _languageController,
                  ),
                ),
                const SizedBox(height: 20),
                _buildChoiceChipSection(
                  'Which generation are you looking for?',
                  _generationOptions,
                  _selectedGeneration,
                      (val) {
                    setState(() => _selectedGeneration = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildChoiceChipSection(
                  'Gender',
                  _genderOptions,
                  _selectedGender,
                      (val) {
                    setState(() => _selectedGender = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildAgeRangeSlider(),
                const SizedBox(height: 20),
                _TitledChipInput(
                  title: 'Which profession are you looking for?',
                  hint: 'Type specific profession',
                  items: _professions,
                  controller: _professionController,
                  onSubmitted: () => _addItemToList(
                    _professionController.text,
                    _professions,
                    _professionController,
                  ),
                ),
                const SizedBox(height: 20),
                _TitledChipInput(
                  title: 'Interest',
                  hint: 'Type specific interest',
                  items: _interests,
                  controller: _interestController,
                  onSubmitted: () => _addItemToList(
                    _interestController.text,
                    _interests,
                    _interestController,
                  ),
                ),
                const SizedBox(height: 32),
                GradientButton(text: 'Search', onPressed: () {}, fontSize: 15, insets: 14),
                if (_isKeyboardVisible) const SizedBox(height: 260),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(fontSize: 16),
    );
  }

  Widget _buildCountryPicker() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: false,
          // UPDATED: Added theme to match sign up screen 2's picker
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
              _selectedCountry = country.countryCode;
            });
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inputBorder, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              Country.tryParse(_selectedCountry)?.flagEmoji ?? '🇺🇦',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                Country.tryParse(_selectedCountry)?.name ?? 'Ukraine',
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
  }

  Widget _buildChoiceChipSection(
      String title,
      List<String> options,
      String? selectedValue,
      ValueChanged<String?> onChanged,
      ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title, textTheme),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                onChanged(selected ? option : null);
              },
              selectedColor: AppColors.primaryRed.withOpacity(0.1),
              backgroundColor: Colors.white,
              labelStyle: textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryRed : AppColors.inputBorder,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAgeRangeSlider() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Age range', textTheme),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RangeSlider(
                values: _currentRangeValues,
                min: 18,
                max: 100,
                divisions: 50,
                activeColor: AppColors.primaryRed,
                inactiveColor: AppColors.inputBorder,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                  });
                },
              ),
            ),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.inputBorder, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${_currentRangeValues.start.round()}-${_currentRangeValues.end.round()}',
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TitledChipInput extends StatefulWidget {
  final String title;
  final String hint;
  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onSubmitted;

  const _TitledChipInput({
    required this.title,
    required this.hint,
    required this.items,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  State<_TitledChipInput> createState() => _TitledChipInputState();
}

class _TitledChipInputState extends State<_TitledChipInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Scrollable.ensureVisible(
            _focusNode.context!,
            alignment: 0.1,
            duration: const Duration(milliseconds: 200),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          focusNode: _focusNode,
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onSubmitted: (_) => widget.onSubmitted(),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.items
              .map(
                (item) => Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  widget.items.remove(item);
                });
              },
              deleteIconColor: AppColors.primaryRed,
              backgroundColor: AppColors.secondaryBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFE9C5C5)),
              ),
              labelStyle: textTheme.bodySmall?.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              deleteIcon: const Icon(Icons.close, size: 16),
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}