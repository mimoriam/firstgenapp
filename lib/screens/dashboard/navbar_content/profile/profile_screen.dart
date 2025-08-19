import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/profile/profile_inner/profile_inner_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables for connection preferences
  String _seeProfileSelection = 'Only Communities I\'m In';
  String _lookingForGenerationSelection = 'First generation';
  String _regionFocusSelection = 'Global';

  // State variables for advanced search filters (moved from search_screen)
  RangeValues _currentRangeValues = const RangeValues(25, 30);
  final List<String> _languages = [];
  final List<String> _professions = [];
  final List<String> _interests = [];
  String? _selectedGender;

  // Options lists
  final List<String> _generationOptions = [
    'First generation',
    'Second generation',
    'Culture enthusiast',
    'Mixed heritage',
    'Not sure',
  ];
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  // Controllers
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  // State variables for notification settings
  bool _appNotifications = true;
  bool _emailUpdates = true;
  bool _eventReminders = false;

  // State variables for privacy controls
  bool _showOnlineStatus = true;
  bool _showJoinedCommunities = true;

  User? _user;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _userProfileStream;
  late FirebaseService _firebaseService;

  @override
  void initState() {
    super.initState();
    // _firebaseService = Provider.of<FirebaseService>(context, listen: false);
    // _user = _firebaseService.currentUser;
    // _userProfileStream = _firebaseService.getUserProfileStream();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firebaseService = Provider.of<FirebaseService>(context);
    _user = _firebaseService.currentUser;
    _userProfileStream = _firebaseService.getUserProfileStream();
  }

  @override
  void dispose() {
    _languageController.dispose();
    _professionController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This Is You', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'View, update, and personalize your profile anytime.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userProfileStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No profile data found.'));
          }

          final userData = snapshot.data!.data();
          _loadPreferences(userData);

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: [
              _buildProfileCard(userData),
              const SizedBox(height: 10),
              _buildConnectionPreferences(),
              const SizedBox(height: 10),
              _buildNotificationSettings(),
              const SizedBox(height: 10),
              _buildPrivacyControls(),
              const SizedBox(height: 10),
              _buildAboutApp(),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }

  void _loadPreferences(Map<String, dynamic>? userData) {
    if (userData == null) return;

    // Load basic preferences
    _seeProfileSelection = userData['seeProfile'] ?? 'Only Communities I\'m In';
    _lookingForGenerationSelection =
        userData['lookingForGeneration'] ?? 'First generation';
    _regionFocusSelection = userData['regionFocus'] ?? 'Global';

    // Load advanced search preferences
    _selectedGender = userData['searchGender'];
    final startAge = userData['searchMinAge']?.toDouble() ?? 25.0;
    final endAge = userData['searchMaxAge']?.toDouble() ?? 30.0;
    _currentRangeValues = RangeValues(startAge, endAge);

    if (userData['searchLanguages'] != null) {
      _languages.clear();
      _languages.addAll(List<String>.from(userData['searchLanguages']));
    }
    if (userData['searchProfessions'] != null) {
      _professions.clear();
      _professions.addAll(List<String>.from(userData['searchProfessions']));
    }
    if (userData['searchInterests'] != null) {
      _interests.clear();
      _interests.addAll(List<String>.from(userData['searchInterests']));
    }
  }

  Widget _buildProfileCard(Map<String, dynamic>? userData) {
    final textTheme = Theme.of(context).textTheme;
    final hasPhoto = _user?.photoURL != null && _user!.photoURL!.isNotEmpty;

    return _buildSectionCard(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.secondaryBackground,
          backgroundImage: hasPhoto ? NetworkImage(_user!.photoURL!) : null,
          child: !hasPhoto
              ? const Icon(
                  IconlyLight.profile,
                  size: 25,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        title: Text(
          userData?['fullName'] ?? _user?.displayName ?? 'No Name',
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          userData?['email'] ?? _user?.email ?? 'No Email',
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.primaryOrange,
        ),
        onTap: () {
          if (context.mounted) {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const ProfileInnerScreen(),
              withNavBar: false,
            );
          }
        },
      ),
    );
  }

  Widget _buildConnectionPreferences() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connection Preferences',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(
                // width: 120,
                child: TextButton(
                  onPressed: _showAdvancedFilters,
                  // fontSize: 12,
                  // insets: 8,
                  child: Row(
                    children: [
                      const Text('More ', style: TextStyle(fontSize: 14)),
                      Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildTitledChipGroup(
            'Who can see your profile?',
            ['Everyone', 'Only Communities I\'m In', 'No Body'],
            _seeProfileSelection,
            (newValue) {
              if (newValue != null) {
                setState(() => _seeProfileSelection = newValue);
                _firebaseService.updateUserProfile({'seeProfile': newValue});
              }
            },
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Which generation are you looking for?',
            _generationOptions,
            _lookingForGenerationSelection,
            (newValue) {
              if (newValue != null) {
                setState(() => _lookingForGenerationSelection = newValue);
                _firebaseService.updateUserProfile({
                  'lookingForGeneration': newValue,
                });
              }
            },
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Region Focus',
            [
              'Africa',
              'Asia',
              'Europe',
              'North America',
              'South America',
              'Oceania',
              'Global',
            ],
            _regionFocusSelection,
            (newValue) {
              if (newValue != null) {
                setState(() => _regionFocusSelection = newValue);
                _firebaseService.updateUserProfile({'regionFocus': newValue});
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Advanced Search Filters',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 24),
                        _buildChoiceChipSection(
                          'Gender',
                          _genderOptions,
                          _selectedGender,
                          (val) {
                            setModalState(() => _selectedGender = val);
                            _firebaseService.updateUserProfile({
                              'searchGender': val,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildAgeRangeSlider((values) {
                          setModalState(() => _currentRangeValues = values);
                          _firebaseService.updateUserProfile({
                            'searchMinAge': values.start.round(),
                            'searchMaxAge': values.end.round(),
                          });
                        }),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Language',
                          hint: 'Type specific language',
                          items: _languages,
                          controller: _languageController,
                          onListChanged: (list) {
                            _firebaseService.updateUserProfile({
                              'searchLanguages': list,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Profession',
                          hint: 'Type specific profession',
                          items: _professions,
                          controller: _professionController,
                          onListChanged: (list) {
                            _firebaseService.updateUserProfile({
                              'searchProfessions': list,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Interest',
                          hint: 'Type specific interest',
                          items: _interests,
                          controller: _interestController,
                          onListChanged: (list) {
                            _firebaseService.updateUserProfile({
                              'searchInterests': list,
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'App Notifications',
            _appNotifications,
            (value) => setState(() => _appNotifications = value),
          ),
          _buildSwitchTile(
            'Email Updates',
            _emailUpdates,
            (value) => setState(() => _emailUpdates = value),
          ),
          _buildSwitchTile(
            'Event Reminders',
            _eventReminders,
            (value) => setState(() => _eventReminders = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Controls',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            'Show online status',
            _showOnlineStatus,
            (value) => setState(() => _showOnlineStatus = value),
          ),
          _buildSwitchTile(
            'Show joined communities on profile',
            _showJoinedCommunities,
            (value) => setState(() => _showJoinedCommunities = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutApp() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About App', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildInfoRow('Terms of Use', onTap: () {}),
          _buildInfoRow('Privacy Policy', onTap: () {}),
          _buildInfoRow('Contact Support', onTap: () {}),
          _buildInfoRow(
            'Log Out',
            onTap: () async {
              await _firebaseService.signOut();
            },
          ),
          _buildInfoRow(
            'App Version',
            trailing: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: child,
    );
  }

  Widget _buildTitledChipGroup(
    String title,
    List<String> options,
    String selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        if (title.isNotEmpty) const SizedBox(height: 12),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) => onChanged(selected ? option : null),
              labelStyle: textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.secondaryBackground,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
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
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primaryRed,
      ),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.primaryOrange,
                )
              : null),
      onTap: onTap,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  // Widgets for the bottom sheet (moved from search_screen)
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
        Text(title, style: textTheme.titleLarge?.copyWith(fontSize: 16)),
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
                color: isSelected
                    ? AppColors.primaryRed
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primaryRed
                      : AppColors.inputBorder,
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

  Widget _buildAgeRangeSlider(ValueChanged<RangeValues> onChanged) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Age range', style: textTheme.titleLarge?.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RangeSlider(
                values: _currentRangeValues,
                min: 18,
                max: 100,
                divisions: 82,
                activeColor: AppColors.primaryRed,
                inactiveColor: AppColors.inputBorder,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: onChanged,
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
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
  final ValueChanged<List<String>> onListChanged;

  const _TitledChipInput({
    required this.title,
    required this.hint,
    required this.items,
    required this.controller,
    required this.onListChanged,
  });

  @override
  State<_TitledChipInput> createState() => _TitledChipInputState();
}

class _TitledChipInputState extends State<_TitledChipInput> {
  void _addItemToList(String item) {
    final trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty && !widget.items.contains(trimmedItem)) {
      setState(() {
        widget.items.add(trimmedItem);
        widget.controller.clear();
        widget.onListChanged(widget.items);
      });
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: textTheme.titleLarge?.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
          onSubmitted: _addItemToList,
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
                      widget.onListChanged(widget.items);
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
