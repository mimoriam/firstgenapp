import 'package:country_picker/country_picker.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/match_detail/match_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/recent_activities/recent_activities_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/your_matches/your_matches_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../../../../common/gradient_btn.dart';

class NewMatchesList extends StatefulWidget {
  const NewMatchesList({super.key});

  @override
  State<NewMatchesList> createState() => _NewMatchesListState();
}

class _NewMatchesListState extends State<NewMatchesList> {
  late Stream<List<Map<String, dynamic>>> _newMatchesStream;

  @override
  void initState() {
    super.initState();
    _newMatchesStream = _fetchNewMatches();
  }

  Stream<List<Map<String, dynamic>>> _fetchNewMatches() {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return firebaseService.getRecentUsers();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _newMatchesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 180,
            child: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 180,
            child: Center(child: Text("No new matches yet.")),
          );
        }
        final matches = snapshot.data!;
        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return _buildMatchCard(matches[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final String? imageUrl = match['imageUrl'];
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final double distance = match['distance'] ?? 2.2;
    final bool isOnline = match['isOnline'] ?? false;

    return GestureDetector(
      onTap: () {
        if (context.mounted) {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: MatchDetailScreen(userProfile: match),
            withNavBar: false,
          );
        }
      },
      child: Container(
        width: 116,
        margin: const EdgeInsets.only(right: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    );
                  },
                )
              else
                Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.person, color: Colors.grey, size: 40),
                  ),
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
              if (match['countryCode'] != null)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildCountryPill(match['countryCode']!),
                  ),
                ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDistancePill(distance),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: "${match['name']}"),
                                if (match['age'] != null)
                                  TextSpan(text: ", ${match['age']}"),
                              ],
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isOnline)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (match['interests'] != null &&
                        (match['interests'] as List).isNotEmpty)
                      Text(
                        (match['interests'] as List<String>)
                            .join(', ')
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: AppColors.primaryRed, width: 1.5),
      ),
      child: Text(
        "$distance km away",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1, // Ensures single line
      ),
    );
  }

  Widget _buildCountryPill(String countryCode) {
    final country = Country.tryParse(countryCode);
    if (country == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(13.0),
        border: Border.all(color: AppColors.primaryRed, width: 1.5),
      ),
      child: Text(
        '${country.flagEmoji} ${country.countryCode}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(int, {int? communitySubTabIndex}) onSwitchTab;

  const HomeScreen({super.key, required this.onSwitchTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firebaseService.getUserProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Container();
          }

          final userData = snapshot.data!.data()!;
          final likesCount = (userData['likedUsers'] as Map?)?.length ?? 0;
          final matchesCount = (userData['matches'] as Map?)?.length ?? 0;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(userData),
                      const SizedBox(height: 12),
                      _buildStatsSection(likesCount, matchesCount),
                      const SizedBox(height: 12),
                      _buildSectionHeader("New Matches"),
                      const SizedBox(height: 10),
                      const NewMatchesList(),
                      const SizedBox(height: 12),
                      _buildSectionHeader("Upcoming Events"),
                      const SizedBox(height: 10),
                      _buildUpcomingEventsList(),
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
        },
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    final textTheme = Theme.of(context).textTheme;
    final String currentDate = DateFormat('d MMMM').format(DateTime.now());
    final String name = userData['fullName'] ?? 'There';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, $name 👋", style: textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                "Here's what's happening in your world today.",
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
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(int likesCount, int matchesCount) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          likesCount.toString(),
          "Likes",
          const Color(0xFFFCE8E8),
          const Color(0xFFC62828),
        ),
        GestureDetector(
          onTap: () {
            if (context.mounted) {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const YourMatchesScreen(),
                withNavBar: false,
              );
            }
          },
          child: _buildStatItem(
            matchesCount.toString(),
            "New Matches",
            const Color(0xFFE8F5E9),
            const Color(0xFF2E7D32),
          ),
        ),
        StreamBuilder<int>(
          stream: firebaseService.unreadMessagesCount,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return GestureDetector(
              onTap: () {
                if (context.mounted) {
                  widget.onSwitchTab(2); // Switch to Chats tab
                }
              },
              child: _buildStatItem(
                count.toString(),
                "Messages",
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
            );
          },
        ),
        StreamBuilder<int>(
          stream: firebaseService.getEventCount(),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return GestureDetector(
              onTap: () {
                if (context.mounted) {
                  widget.onSwitchTab(3, communitySubTabIndex: 2);
                }
              },
              child: _buildStatItem(
                count.toString(),
                "Events",
                const Color(0xFFFFFDE7),
                const Color(0xFFF9A825),
              ),
            );
          },
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
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: () {
            if (context.mounted) {
              if (title == "New Matches") {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const YourMatchesScreen(),
                  withNavBar: false,
                );
              } else if (title == "Upcoming Events") {
                if (context.mounted) {
                  widget.onSwitchTab(3, communitySubTabIndex: 2);
                }
              } else {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const RecentActivitiesScreen(),
                  withNavBar: false,
                );
              }
            }
          },
          child: Text(
            "See All",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryRed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventsList() {
    return Consumer<CommunityViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingEvents) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.upcomingEvents.isEmpty) {
          return const Center(child: Text("No upcoming events."));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: viewModel.upcomingEvents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return EventCard(
              event: viewModel.upcomingEvents[index],
              onSwitchTab: widget.onSwitchTab,
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivityList() {
    final List<Map<String, dynamic>> activities = [
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _buildActivityItem(activities[index]);
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
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
  final Event event;
  final bool? copied;
  final Function(int, {int? communitySubTabIndex})? onSwitchTab;

  const EventCard({
    super.key,
    required this.event,
    this.copied,
    this.onSwitchTab,
  });

  @override
  _EventCardState createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late bool _isInterested;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<FirebaseService>(
      context,
      listen: false,
    ).currentUser?.uid;
    _isInterested = widget.event.interestedUserIds.contains(userId);
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final currentUserId = firebaseService.currentUser?.uid;
    final isCreator = widget.event.creatorId == currentUserId;

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
                widget.event.imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.event.title, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                _buildInfoItem(
                  Iconsax.calendar,
                  DateFormat(
                    'd MMMM, yyyy',
                  ).format(widget.event.eventDate.toDate()),
                  const Color(0xFF009E60),
                ),
                _buildInfoItem(
                  Iconsax.location,
                  widget.event.location,
                  const Color(0xFFF7C108),
                ),
                _buildInfoItem(
                  Iconsax.profile_2user,
                  "${widget.event.interestedUserIds.length} Attending",
                  const Color(0xFF0A75BA),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                          onPressed: isCreator
                              ? null
                              : () {
                                  if (currentUserId != null) {
                                    firebaseService.toggleEventInterest(
                                      widget.event.id,
                                      currentUserId,
                                    );
                                    setState(() {
                                      _isInterested = false;
                                    });
                                  }
                                },
                          fontSize: 13,
                          insets: 10,
                        )
                      : OutlinedButton(
                          onPressed: () {
                            if (currentUserId != null) {
                              firebaseService.toggleEventInterest(
                                widget.event.id,
                                currentUserId,
                              );
                              setState(() {
                                _isInterested = true;
                              });
                            }
                          },
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
                    onPressed: () async {
                      final community = await firebaseService.getCommunityById(
                        widget.event.communityId,
                      );
                      if (community != null && context.mounted) {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen:
                              ChangeNotifierProvider<CommunityViewModel>.value(
                                value: Provider.of<CommunityViewModel>(
                                  context,
                                  listen: false,
                                ),
                                child: CommunityDetailScreen(
                                  community: community,
                                ),
                              ),
                          withNavBar: false,
                        );
                      }
                    },
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
