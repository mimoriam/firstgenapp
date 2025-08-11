import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/match_detail/match_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/recent_activities/recent_activities_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/your_matches/your_matches_screen.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart'; // Needed for ImageFilter.blur

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _matches = [
    {
      "name": "James",
      "age": 20,
      "distance": 2.2,
      "interests": "MUSIC, COFFEE",
      "country": "Indian",
      "isOnline": true,
      "image":
          "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&q=80",
    },
    {
      "name": "Jessica",
      "age": 22,
      "distance": 2.2,
      "interests": "ART, MOVIES",
      "country": "German",
      "isOnline": false,
      "image":
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&q=80",
    },
    {
      "name": "Carlos",
      "age": 25,
      "distance": 2.2,
      "interests": "DANCE, FOOD",
      "country": "Spanish",
      "isOnline": true,
      "image":
          "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&q=80",
    },
    {
      "name": "Priya",
      "age": 21,
      "distance": 5.0,
      "interests": "TRAVEL, BOOKS",
      "country": "Indian",
      "isOnline": false,
      "image":
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&q=80",
    },
  ];

  final List<Map<String, dynamic>> _events = [
    {
      "image": "https://picsum.photos/seed/e1/400/200",
      "title": "Diwali Cooking Workshop",
      "date": "8 December, 2025",
      "location": "Spice Garden Kitchen",
      "description":
          "Soothing audio and gentle vibrations to ease discomfort. Soothing audio and gentle vibrations to.",
      "attendees": 31,
      "isInterested": true,
    },
    {
      "image": "https://picsum.photos/seed/e2/400/200",
      "title": "Cultural Music Night",
      "date": "15 December, 2025",
      "location": "The Grand Hall",
      "description":
          "Experience the rich musical traditions from around the world. A night of melody and harmony.",
      "attendees": 85,
      "isInterested": false,
    },
  ];

  final List<Map<String, dynamic>> _activities = [
    {
      "avatar":
          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80",
      "text": "Maria Santos liked your profile",
      "time": "2 hours ago",
    },
    {
      "avatar":
          "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100&q=80",
      "text": "You matched with Leila Okafor",
      "time": "2 hours ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildStatsSection(),
                const SizedBox(height: 12),
                _buildSectionHeader("New Matches"),
                const SizedBox(height: 10),
                _buildNewMatchesList(),
                const SizedBox(height: 12),
                _buildSectionHeader("Recent Events"),
                const SizedBox(height: 10),
                _buildRecentEventsList(),
                const SizedBox(height: 12),
                _buildSectionHeader("Recent Activity"),
                const SizedBox(height: 10),
                _buildRecentActivityList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final textTheme = Theme.of(context).textTheme;
    final String currentDate = DateFormat('d MMMM').format(DateTime.now());

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, Lily 👋",
                // UPDATED: Inherited from theme
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                "Here's what's happening in your world today.",
                // UPDATED: Inherited from theme
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Today, $currentDate",
            // UPDATED: Inherited from theme
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          "12",
          "Likes",
          const Color(0xFFFCE8E8),
          const Color(0xFFC62828),
        ),
        _buildStatItem(
          "3",
          "New Matches",
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
        ),
        _buildStatItem(
          "5",
          "Messages",
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
        ),
        _buildStatItem(
          "6",
          "Events",
          const Color(0xFFFFFDE7),
          const Color(0xFFF9A825),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String count,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Column(
      children: [
        Container(
          // UPDATED: Reduced size for compactness
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              count,
              style: TextStyle(
                // UPDATED: Reduced font size
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          // UPDATED: Inherited from theme
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          // UPDATED: Inherited from theme
          style: Theme.of(context).textTheme.titleLarge,
        ),
        TextButton(
          onPressed: () {
            if (context.mounted) {
              if (title == "New Matches") {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: YourMatchesScreen(),
                  withNavBar: false,
                );
              } else if (title == "Recent Events") {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: RecentActivitiesScreen(),
                  withNavBar: false,
                );
              } else {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: RecentActivitiesScreen(),
                  withNavBar: false,
                );
              }
            }
          },
          child: Text(
            "See All",
            // UPDATED: Inherited from theme
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewMatchesList() {
    return SizedBox(
      // UPDATED: Reduced height for compactness
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _matches.length,
        itemBuilder: (context, index) {
          return _buildMatchCard(_matches[index]);
        },
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MatchDetailScreen(),
            withNavBar: false,
          );
        }
      },
      child: Container(
        // UPDATED: Reduced width for compactness
        width: 110,
        margin: const EdgeInsets.only(right: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                match['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              if (match['country'] != null && match['country']!.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: _buildCountryPill(match['country']!),
                ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDistancePill(match['distance']),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "${match['name']}, ${match['age']}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              // UPDATED: Reduced font size
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (match['isOnline'] == true)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      match['interests'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        // UPDATED: Reduced font size
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistancePill(double distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        "$distance km away",
        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10),
      ),
    );
  }

  Widget _buildCountryPill(String country) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: AppColors.primaryRed, width: 1.5),
      ),
      child: Text(
        country,
        style: const TextStyle(
          color: Colors.white,
          // UPDATED: Reduced font size
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRecentEventsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return EventCard(event: _events[index]);
      },
    );
  }

  Widget _buildRecentActivityList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildActivityItem(_activities[index]);
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(activity['avatar']),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['text'],
                  // UPDATED: Inherited from theme
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
                  // UPDATED: Inherited from theme
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool? copied;

  const EventCard({super.key, required this.event, this.copied});

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late bool _isInterested;

  @override
  void initState() {
    super.initState();
    _isInterested = widget.event['isInterested'];
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          // UPDATED: Inherited from theme
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            // color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // UPDATED: Consistent button style for this card
    final buttonStyle = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.event['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.event['title'],
              // UPDATED: Inherited from theme
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildInfoItem(
                  // Icons.calendar_today,
                  Iconsax.calendar,
                  widget.event['date'],
                  // Colors.green.shade700,
                  Color(0xFF009E60),
                ),
                _buildInfoItem(
                  Iconsax.location,
                  widget.event['location'],
                  // Colors.yellow.shade700,
                  Color(0xFFF7C108),
                ),
                _buildInfoItem(
                  Iconsax.profile_2user,
                  "${widget.event['attendees']} Attending",
                  // Colors.blue.shade700,
                  Color(0xFF0A75BA),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.event['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              // UPDATED: Inherited from theme
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isInterested
                      ? GradientButton(
                          text: "I'm Interested",
                          onPressed: () {
                            setState(() {
                              _isInterested = false;
                            });
                          },
                          // UPDATED: Matched font size and padding
                          fontSize: 13,
                          insets: 10,
                        )
                      : OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _isInterested = true;
                            });
                          },
                          // UPDATED: Matched style
                          style: buttonStyle.copyWith(
                            side: MaterialStateProperty.all(
                              const BorderSide(color: AppColors.primaryRed),
                            ),
                            foregroundColor: MaterialStateProperty.all(
                              AppColors.primaryRed,
                            ),
                          ),
                          child: const Text("I'm Interested"),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: CommunityDetailScreen(),
                        withNavBar: false,
                      );
                    },
                    // UPDATED: Matched style
                    style: buttonStyle.copyWith(
                      backgroundColor: MaterialStateProperty.all(
                        AppColors.secondaryBackground,
                      ),
                      foregroundColor: MaterialStateProperty.all(
                        AppColors.primaryRed,
                      ),
                    ),
                    child: const Text("View Community"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
