import 'package:firstgenapp/screens/profile/profile_inner_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State variables for connection preferences
  String _seeProfileSelection = 'Only Communities I\'m In';
  String _connectWithSelection = 'Connect With';
  String _lookingForSelection = 'First Generation';
  String _regionFocusSelection = 'Africa';

  // State variables for notification settings
  bool _appNotifications = true;
  bool _emailUpdates = true;
  bool _eventReminders = false;

  // State variables for privacy controls
  bool _showOnlineStatus = true;
  bool _showJoinedCommunities = true;

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
            Text(
              'This Is You',
              // UPDATED: Inherited from theme
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'View, update, and personalize your profile anytime.',
              // UPDATED: Inherited from theme
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          _buildProfileCard(),
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
      ),
    );
  }

  Widget _buildProfileCard() {
    final textTheme = Theme.of(context).textTheme;
    return _buildSectionCard(
      child: ListTile(
        leading: const CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            'https://randomuser.me/api/portraits/men/75.jpg',
          ),
        ),
        title: Text(
          'Rana Utban',
          // UPDATED: Inherited from theme
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'ranautban007@gmail.com',
          // UPDATED: Inherited from theme
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.textSecondary,
        ),
        onTap: () {
          if (context.mounted) {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: ProfileInnerScreen(),
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
          Text(
            'Connection Preferences',
            // UPDATED: Inherited from theme
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Who can see your profile?',
            ['Everyone', 'Only Communities I\'m In'],
            _seeProfileSelection,
                (newValue) => setState(() => _seeProfileSelection = newValue!),
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            '', // No title for this group
            ['People', 'Connect With'],
            _connectWithSelection,
                (newValue) => setState(() => _connectWithSelection = newValue!),
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Looking to connect with',
            ['First Generation', 'Culture Enthusiasts', 'Both'],
            _lookingForSelection,
                (newValue) => setState(() => _lookingForSelection = newValue!),
          ),
          const SizedBox(height: 16),
          _buildTitledChipGroup(
            'Region Focus',
            ['Africa', 'Asia', 'Europe', 'Global'],
            _regionFocusSelection,
                (newValue) => setState(() => _regionFocusSelection = newValue!),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Settings',
            // UPDATED: Inherited from theme
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
            // UPDATED: Inherited from theme
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
          Text(
            'About App',
            // UPDATED: Inherited from theme
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Terms of Use', onTap: () {}),
          _buildInfoRow('Privacy Policy', onTap: () {}),
          _buildInfoRow('Contact Support', onTap: () {}),
          _buildInfoRow('Log Out', onTap: () {}),
          _buildInfoRow('Delete My Account', onTap: () {}),
          _buildInfoRow(
            'App Version',
            trailing: Text(
              'v1.0.0',
              // UPDATED: Inherited from theme
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
          Text(title, style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
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
              // UPDATED: Compacted chip style
              labelStyle: textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primaryRed : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: AppColors.secondaryBackground,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryRed : AppColors.inputBorder,
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
              // UPDATED: Compacted chip padding
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
    return SwitchListTile(
      title: Text(
        title,
        // UPDATED: Inherited from theme
        style: Theme.of(context).textTheme.labelLarge,
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryRed,
      // UPDATED: Made tile more compact
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      trailing: trailing ??
          (onTap != null
              ? const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textSecondary,
          )
              : null),
      onTap: onTap,
      // UPDATED: Made tile more compact
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}