import 'dart:ui';

import 'package:firstgenapp/models/activity_model.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/match_detail/match_detail_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class RecentActivitiesScreen extends StatefulWidget {
  const RecentActivitiesScreen({super.key});

  @override
  State<RecentActivitiesScreen> createState() => _RecentActivitiesScreenState();
}

class _RecentActivitiesScreenState extends State<RecentActivitiesScreen> {
  late Stream<List<Activity>> _activityStream;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    _activityStream = firebaseService.getRecentActivities();
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Recent Activities', style: textTheme.headlineSmall),
      ),
      body: StreamBuilder<List<Activity>>(
        stream: _activityStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recent activities.'));
          }
          final activities = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityItem(activities[index], textTheme);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 8),
          );
        },
      ),
    );
  }

  Widget _buildActivityItem(Activity activity, TextTheme textTheme) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        final isPremium = subscriptionProvider.isPremium;
        String text = '';

        if (isPremium) {
          switch (activity.type) {
            case ActivityType.liked:
              text = '${activity.fromUserName} liked your profile';
              break;
            case ActivityType.matched:
              text = 'You matched with ${activity.fromUserName}';
              break;
          }
        } else {
          switch (activity.type) {
            case ActivityType.liked:
              text = 'Someone liked your profile';
              break;
            case ActivityType.matched:
              text = 'You have a new match';
              break;
          }
        }

        return TapDebouncer(
          cooldown: const Duration(milliseconds: 1000),
          onTap: () async {
            if (isPremium) {
              final firebaseService = Provider.of<FirebaseService>(
                context,
                listen: false,
              );
              final userDoc = await firebaseService.getUserDocument(
                activity.fromUserId,
              );
              if (userDoc != null && userDoc.exists) {
                final userData = userDoc.data();
                if (userData != null && context.mounted) {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: MatchDetailScreen(userProfile: userData),
                    withNavBar: false,
                  );
                }
              }
            }
          },
          builder: (BuildContext context, TapDebouncerFunc? onTap) {
            return GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.inputBorder.withOpacity(0.7),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(activity.fromUserAvatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: isPremium ? 0 : 9,
                              sigmaY: isPremium ? 0 : 9,
                            ),
                            child: Text(
                              text,
                              style: textTheme.labelLarge?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            TimeAgo.format(
                              activity.timestamp.toDate().toIso8601String(),
                            ),
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
