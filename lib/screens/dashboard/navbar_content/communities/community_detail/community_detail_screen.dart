import 'dart:ui';

import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/common/post_card.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/create_event_screen/create_event_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;
  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      floatingActionButton: Visibility(
        visible: _currentTabIndex == 2,
        child: FloatingActionButton(
          onPressed: () {
            if (context.mounted) {
              final viewModel = Provider.of<CommunityViewModel>(
                context,
                listen: false,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider.value(
                    value: viewModel,
                    child: CreateEventScreen(communityId: widget.community.id),
                  ),
                ),
              );
            }
          },
          backgroundColor: Colors.transparent,
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF212221).withOpacity(0.1),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryRed, AppColors.primaryOrange],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.primaryBackground,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(''),
              pinned: true,
              floating: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(200),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  child: Consumer<CommunityViewModel>(
                    builder: (context, viewModel, child) {
                      return _buildHeaderCard(viewModel);
                    },
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryRed,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: textTheme.labelLarge,
                  tabs: const [
                    Tab(text: 'About Community'),
                    Tab(text: 'Feed'),
                    Tab(text: 'Upcoming Events'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _AboutTab(community: widget.community),
            _FeedTab(community: widget.community),
            _UpcomingEventsTab(community: widget.community),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(CommunityViewModel viewModel) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser?.uid;
    
    // Get the updated community data from the viewModel
    final community = viewModel.allCommunities.firstWhere(
      (c) => c.id == widget.community.id,
      orElse: () => widget.community,
    );
    
    final isMember = community.members.contains(userId);
    final isCreator = community.creatorId == userId;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(community.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withAlpha(178),
              Colors.black.withAlpha(102),
              Colors.transparent,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                community.name,
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${community.members.length} members',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                community.description,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(230),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Visibility(
                visible: !isMember && !isCreator,
                child: ElevatedButton(
                  onPressed: () {
                    firebaseService
                        .joinCommunity(community.id, userId!)
                        .then((_) => viewModel.refreshAllData());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tertiaryBackground,
                    foregroundColor: AppColors.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(
                      color: AppColors.primaryRed,
                      width: 1.2,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Join Community',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final Community community;
  const _FeedTab({required this.community});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return StreamBuilder<List<Post>>(
      stream: firebaseService.getPostsForCommunityStream(community.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No posts in this community yet.'));
        }
        final posts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.only(
            top: 16,
            left: 12,
            right: 12,
            bottom: 16,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostCard(key: ValueKey(post.id), post: post);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        );
      },
    );
  }
}

class _AboutTab extends StatelessWidget {
  final Community community;
  const _AboutTab({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome to ${community.name} ',
                  style: textTheme.titleLarge,
                ),
                const TextSpan(text: '👋', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            community.description,
            style: textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildExpansionTile(
            title: 'What is this community for?',
            content: community.whoFor,
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            title: 'What will you gain from this community?',
            content: community.whatToGain,
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            title: 'Community Rules',
            content: community.rules,
            isInitiallyExpanded: false,
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required String content,
    bool isInitiallyExpanded = true,
  }) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
        initiallyExpanded: isInitiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        tilePadding: EdgeInsets.zero,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              content,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingEventsTab extends StatelessWidget {
  final Community community;
  const _UpcomingEventsTab({required this.community});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return StreamBuilder<List<Event>>(
      stream: firebaseService.getEventsForCommunity(community.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No upcoming events.'));
        }
        final events = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(12.0),
          itemCount: events.length,
          itemBuilder: (context, index) => EventCard(event: events[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: AppColors.primaryBackground, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class EventCard extends StatefulWidget {
  final Event event;

  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
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
                          insets: 13,
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
