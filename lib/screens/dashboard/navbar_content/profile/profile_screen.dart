import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/constants/appVersion.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/profile/profile_inner/profile_inner_screen.dart';
import 'package:firstgenapp/screens/subscription/subscription_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/services/notification_service.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _interestController = TextEditingController();

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  bool _showJoinedCommunities = true;

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
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final user = firebaseService.currentUser;
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);

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
      body: Consumer<UserProfileViewModel>(
        builder: (context, userProfileViewModel, child) {
          if (userProfileViewModel.isLoading ||
              userProfileViewModel.userProfileData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userProfileViewModel.userProfileData!;
          final bool appNotifications =
              userData['appNotificationsEnabled'] ?? true;
          final bool eventReminders =
              userData['eventRemindersEnabled'] ?? false;
          _showJoinedCommunities = userData['showJoinedCommunities'] ?? true;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            children: [
              _buildProfileCard(
                userData,
                user,
                textTheme,
                subscriptionProvider.isPremium,
              ),
              const SizedBox(height: 10),
              if (!subscriptionProvider.isPremium) ...[
                _buildUpgradeCard(),
                const SizedBox(height: 10),
              ] else ...[
                _buildSubscribedCard(userData, textTheme),
                const SizedBox(height: 10),
              ],
              _buildConnectionPreferences(userData, firebaseService),
              const SizedBox(height: 10),
              _buildNotificationSettings(appNotifications, eventReminders),
              const SizedBox(height: 10),
              _buildPrivacyControls(),
              const SizedBox(height: 10),
              _buildAboutApp(firebaseService),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
  // lib/screens/dashboard/navbar_content/profile/profile_screen.dart

  Widget _buildProfileCard(
    Map<String, dynamic> userData,
    User? user,
    TextTheme textTheme,
    bool isPremium,
  ) {
    final imageUrl = userData['profileImageUrl'];
    final hasPhoto = imageUrl != null && imageUrl.isNotEmpty;

    return _buildSectionCard(
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.secondaryBackground,
          backgroundImage: hasPhoto ? NetworkImage(imageUrl) : null,
          child: !hasPhoto
              ? const Icon(
                  IconlyLight.profile,
                  size: 25,
                  color: AppColors.textSecondary,
                )
              : null,
        ),
        title: Row(
          children: [
            // This Flexible widget prevents the text from overflowing
            Flexible(
              child: Text(
                userData['fullName'] ?? user?.displayName ?? 'No Name',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis, // Add ellipsis for long names
              ),
            ),
            if (isPremium) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Premium',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          userData['email'] ?? user?.email ?? 'No Email',
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

  Widget _buildUpgradeCard() {
    return GestureDetector(
      onTap: () {
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const SubscriptionScreen(),
          withNavBar: false,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryRed, AppColors.primaryOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(IconlyBold.star, color: Colors.white, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to Premium',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Unlock all features and get the best experience.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  /// New widget to display when the user is subscribed.
  /// It shows their premium status and subscription end date.
  Widget _buildSubscribedCard(
    Map<String, dynamic> userData,
    TextTheme textTheme,
  ) {
    // Safely get the subscription plan, defaulting to 'Premium'.
    final plan =
        (userData['subscriptionPlan'] as String?)?.capitalize() ?? 'Premium';

    // Safely get and format the subscription end date.
    final endDateTimestamp = userData['subscriptionEndDate'] as Timestamp?;
    String endDate = 'N/A';
    if (endDateTimestamp != null) {
      endDate = DateFormat('MMMM d, yyyy').format(endDateTimestamp.toDate());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade600,
            Colors.green.shade400,
          ], // Green for active subscription
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(IconlyBold.shield_done, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are a Premium Member!',
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your $plan plan is active until $endDate.',
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionPreferences(
    Map<String, dynamic> userData,
    FirebaseService firebaseService,
  ) {
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
              TextButton(
                onPressed: () => _showAdvancedFilters(userData),
                child: const Row(
                  children: [
                    Text('More ', style: TextStyle(fontSize: 14)),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildTitledChipGroup(
            'Who can see your profile?',
            ['Everyone', 'Nobody'],
            userData['seeProfile'] ?? 'Everyone',
            (newValue) {
              if (newValue != null) {
                Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                ).updateLocalProfileData({'seeProfile': newValue});
                firebaseService.updateUserProfile({'seeProfile': newValue});
              }
            },
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Which generation are you looking for?',
            [
              'First generation',
              'Second generation',
              'Culture enthusiast',
              'Mixed heritage',
              'Not sure',
            ],
            userData['lookingForGeneration'] ?? 'First generation',
            (newValue) {
              if (newValue != null) {
                Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                ).updateLocalProfileData({'lookingForGeneration': newValue});
                firebaseService.updateUserProfile({
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
            userData['regionFocus'] ?? 'Global',
            (newValue) {
              if (newValue != null) {
                Provider.of<UserProfileViewModel>(
                  context,
                  listen: false,
                ).updateLocalProfileData({'regionFocus': newValue});
                firebaseService.updateUserProfile({'regionFocus': newValue});
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters(Map<String, dynamic> initialUserData) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userProfileViewModel = Provider.of<UserProfileViewModel>(
      context,
      listen: false,
    );

    String? selectedGender = initialUserData['searchGender'];
    RangeValues currentRangeValues = RangeValues(
      initialUserData['searchMinAge']?.toDouble() ?? 25.0,
      initialUserData['searchMaxAge']?.toDouble() ?? 30.0,
    );
    List<String> languages = List<String>.from(
      initialUserData['searchLanguages'] ?? [],
    );
    List<String> professions = List<String>.from(
      initialUserData['searchProfessions'] ?? [],
    );
    List<String> interests = List<String>.from(
      initialUserData['searchInterests'] ?? [],
    );

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
                          selectedGender,
                          (val) {
                            setModalState(() => selectedGender = val);
                            userProfileViewModel.updateLocalProfileData({
                              'searchGender': val,
                            });
                            firebaseService.updateUserProfile({
                              'searchGender': val,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildAgeRangeSlider(currentRangeValues, (values) {
                          setModalState(() => currentRangeValues = values);
                          userProfileViewModel.updateLocalProfileData({
                            'searchMinAge': values.start.round(),
                            'searchMaxAge': values.end.round(),
                          });
                          firebaseService.updateUserProfile({
                            'searchMinAge': values.start.round(),
                            'searchMaxAge': values.end.round(),
                          });
                        }),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Language',
                          hint: 'Type specific language',
                          items: languages,
                          controller: _languageController,
                          onListChanged: (list) {
                            userProfileViewModel.updateLocalProfileData({
                              'searchLanguages': list,
                            });
                            firebaseService.updateUserProfile({
                              'searchLanguages': list,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Profession',
                          hint: 'Type specific profession',
                          items: professions,
                          controller: _professionController,
                          onListChanged: (list) {
                            userProfileViewModel.updateLocalProfileData({
                              'searchProfessions': list,
                            });
                            firebaseService.updateUserProfile({
                              'searchProfessions': list,
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        _TitledChipInput(
                          title: 'Interest',
                          hint: 'Type specific interest',
                          items: interests,
                          controller: _interestController,
                          onListChanged: (list) {
                            userProfileViewModel.updateLocalProfileData({
                              'searchInterests': list,
                            });
                            firebaseService.updateUserProfile({
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

  Widget _buildNotificationSettings(
    bool appNotifications,
    bool eventReminders,
  ) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildSwitchTile('App Notifications', appNotifications, (value) {
            Provider.of<UserProfileViewModel>(
              context,
              listen: false,
            ).updateLocalProfileData({'appNotificationsEnabled': value});
            final firebaseService = Provider.of<FirebaseService>(
              context,
              listen: false,
            );
            firebaseService.updateUserProfile({
              'appNotificationsEnabled': value,
            });
          }),
          _buildSwitchTile('Event Reminders', eventReminders, (value) async {
            Provider.of<UserProfileViewModel>(
              context,
              listen: false,
            ).updateLocalProfileData({'eventRemindersEnabled': value});
            final firebaseService = Provider.of<FirebaseService>(
              context,
              listen: false,
            );
            await firebaseService.updateUserProfile({
              'eventRemindersEnabled': value,
            });

            final notificationService = NotificationService();
            if (value) {
              final events = Provider.of<CommunityViewModel>(
                context,
                listen: false,
              ).upcomingEvents;
              await notificationService.scheduleEventReminders(events);
            } else {
              await notificationService.cancelAllEventReminders();
            }
          }),
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
            'Show joined communities on profile',
            _showJoinedCommunities,
            (value) {
              setState(() => _showJoinedCommunities = value);
              Provider.of<FirebaseService>(
                context,
                listen: false,
              ).updateUserProfile({'showJoinedCommunities': value});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutApp(FirebaseService firebaseService) {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About App', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // _buildInfoRow('Privacy Policy', onTap: () {}),
          // _buildInfoRow('Contact Support', onTap: () {}),
          _buildInfoRow(
            'Log Out',
            onTap: () async {
              await firebaseService.signOut();
            },
          ),
          _buildInfoRow(
            'App Version',
            trailing: Text(
              'v$appVersion',
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

  Widget _buildAgeRangeSlider(
    RangeValues currentRangeValues,
    ValueChanged<RangeValues> onChanged,
  ) {
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
                values: currentRangeValues,
                min: 18,
                max: 100,
                divisions: 82,
                activeColor: AppColors.primaryRed,
                inactiveColor: AppColors.inputBorder,
                labels: RangeLabels(
                  currentRangeValues.start.round().toString(),
                  currentRangeValues.end.round().toString(),
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
                  '${currentRangeValues.start.round()}-${currentRangeValues.end.round()}',
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
