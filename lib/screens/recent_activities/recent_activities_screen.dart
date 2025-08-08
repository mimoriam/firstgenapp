import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class RecentActivitiesScreen extends StatefulWidget {
  const RecentActivitiesScreen({super.key});

  @override
  State<RecentActivitiesScreen> createState() => _RecentActivitiesScreenState();
}

class _RecentActivitiesScreenState extends State<RecentActivitiesScreen> {
  // Mock data for recent activities
  final List<Map<String, String>> _activities = [
    {
      "avatar": "https://randomuser.me/api/portraits/women/1.jpg",
      "text": "Maria Santos liked your profile",
      "time": "2 hours ago",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/women/2.jpg",
      "text": "You matched with Leila Okafor",
      "time": "2 hours ago",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/men/1.jpg",
      "text": "You matched with Leila Okafor",
      "time": "2 hours ago",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/men/2.jpg",
      "text": "You matched with Leila Okafor",
      "time": "2 hours ago",
    },
    {
      "avatar": "https://randomuser.me/api/portraits/women/3.jpg",
      "text": "You matched with Leila Okafor",
      "time": "2 hours ago",
    },
  ];

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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recent Activities',
          // UPDATED: Inherited from theme
          style: textTheme.headlineSmall,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          return _buildActivityItem(_activities[index], textTheme);
        },
        // UPDATED: Reduced spacing between items
        separatorBuilder: (context, index) => const SizedBox(height: 8),
      ),
    );
  }

  /// Builds a single activity item card.
  Widget _buildActivityItem(
      Map<String, String> activity, TextTheme textTheme) {
    return Container(
      // UPDATED: Reduced vertical padding
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            // UPDATED: Reduced size
            radius: 22,
            backgroundImage: NetworkImage(activity['avatar']!),
          ),
          // UPDATED: Reduced spacing
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['text']!,
                  // UPDATED: Inherited from theme
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time']!,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}