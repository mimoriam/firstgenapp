import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/all_communities/all_communities_screen.dart';
import 'package:firstgenapp/screens/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/screens/create_community/create_community_screen.dart';
import 'package:firstgenapp/screens/create_event_screen/create_event_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mock Data
  final List<Map<String, String>> _communities = [
    {
      'name': 'Latino Link',
      'avatar': 'https://randomuser.me/api/portraits/women/68.jpg',
    },
    {
      'name': 'Desi Vibes',
      'avatar': 'https://randomuser.me/api/portraits/women/69.jpg',
    },
    {
      'name': 'Asia Pulse',
      'avatar': 'https://randomuser.me/api/portraits/men/70.jpg',
    },
    {
      'name': 'Global Fam',
      'avatar': 'https://randomuser.me/api/portraits/men/71.jpg',
    },
    {
      'name': 'Culture Mix',
      'avatar': 'https://randomuser.me/api/portraits/women/72.jpg',
    },
    {
      'name': 'Heritage Hub',
      'avatar': 'https://randomuser.me/api/portraits/men/73.jpg',
    },
  ];

  final List<Map<String, dynamic>> _posts = [
    {
      'name': 'Ariana',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
      'time': '17 July at 08:02 AM',
      'community': 'Reiki Healing',
      'image':
      'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=500&q=80',
      'caption':
      'My daughter just got diagnosed with ANOREXIA. Feeling overwhelmed. Any advice?',
      'likes': 45,
      'comments': 12,
      'shares': 2,
    },
    {
      'name': 'Ariana',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
      'time': '17 July at 08:00 AM',
      'community': 'Reiki Healing',
      'title': 'This is what I learned in my recent course',
      'quote':
      '"The whole secret of existence lies in the pursuit of meaning, purpose, and connection. It is a delicate dance between self-discovery, compassion for others, and embracing the ever-unfolding mysteries of life. Finding harmony in the ebb and flow of experiences, we unlock the profound beauty that resides within our shared journey."',
      'likes': 45,
      'comments': 12,
      'shares': 2,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Explore Communities', style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Culture starts with connection', style: textTheme.bodySmall),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (context.mounted) {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: CreateCommunityScreen(),
                  withNavBar: false,
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Iconsax.add_square_copy,
                color: AppColors.primaryRed,
                size: 24,
              ),
            ),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: _buildAllCommunities()),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryRed,
                  indicatorSize: TabBarIndicatorSize.label,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  dividerColor: Colors.transparent,
                  labelStyle: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: textTheme.labelLarge,
                  tabs: const [
                    Tab(text: 'My feed'),
                    Tab(text: 'My communities'),
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
          children: [buildFeed(), _MyCommunitiesTab(), _UpcomingEventsTab()],
        ),
      ),
    );
  }

  Widget _buildAllCommunities() {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Communities', style: textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    if (context.mounted) {
                      PersistentNavBarNavigator.pushNewScreen(
                        context,
                        screen: AllCommunitiesScreen(),
                        withNavBar: false,
                      );
                    }
                  },
                  child: Text(
                    'View All',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _communities.length,
              itemBuilder: (context, index) {
                final community = _communities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(community['avatar']!),
                      ),
                      const SizedBox(height: 6),
                      Text(community['name']!, style: textTheme.bodySmall),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: To match the new design in the screenshot
  Widget _buildCreatePostSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UPDATED: Header is now outside the card
        Text(
          '👋 Good to see you again!',
          style: textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          "Here's a real-time view of what needs your attention today.",
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://randomuser.me/api/portraits/men/75.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "What's on your mind? Ask a question or share your story..",
                  style: textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(IconlyLight.camera,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              const Icon(Icons.attach_file_outlined,
                  color: AppColors.textSecondary, size: 22),
              const SizedBox(width: 12),
              const Icon(Icons.emoji_emotions_outlined,
                  color: AppColors.textSecondary, size: 22),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(Iconsax.global_copy,
                  color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 4),
              Text('Add your post in', style: textTheme.labelLarge),
              const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  if (context.mounted) {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen:
                      CreateEventScreen(), // Assuming this is the correct screen
                      withNavBar: false,
                    );
                  }
                },
                icon: const Icon(IconlyLight.send, size: 18),
                label: const Text('Post Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFeed() {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildCreatePostSection();
        }
        return _PostCard(post: _posts[index - 1]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }
}

class _MyCommunitiesTab extends StatelessWidget {
  final List<Map<String, dynamic>> _createdCommunities = [
    {
      'name': 'Reiki Healing',
      'rating': 4.3,
      'members': '10K+',
      'image':
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
    },
    {
      'name': 'Yoga & Meditation',
      'rating': 4.8,
      'members': '25K+',
      'image':
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
    },
  ];

  final List<Map<String, dynamic>> _joinedCommunities = [
    {
      'name': 'Spiritual Awakening',
      'rating': 4.5,
      'members': '15K+',
      'image':
      'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
    },
    {
      'name': 'Holistic Health',
      'rating': 4.6,
      'members': '18K+',
      'image':
      'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=500&q=80',
    },
    {
      'name': 'Mindfulness Practices',
      'rating': 4.7,
      'members': '22K+',
      'image':
      'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Communities I Created', context),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _createdCommunities.length,
          itemBuilder: (context, index) =>
              _CommunityListCard(community: _createdCommunities[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Communities I Joined', context),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _joinedCommunities.length,
          itemBuilder: (context, index) =>
              _CommunityListCard(community: _joinedCommunities[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _CommunityListCard extends StatelessWidget {
  final Map<String, dynamic> community;

  const _CommunityListCard({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              community['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community['name'],
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '${community['rating']} (${community['members']} members)',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: CommunityDetailScreen(),
                          withNavBar: false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.red),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      textStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
                    ),
                    child: const Text(
                      'View Community',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEventsTab extends StatelessWidget {
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
      "hasVideo": false,
    },
    {
      "image": "https://picsum.photos/seed/e1/400/200",
      "title": "Diwali Cooking Workshop",
      "date": "8 December, 2025",
      "location": "Spice Garden Kitchen",
      "description":
      "Soothing audio and gentle vibrations to ease discomfort. Soothing audio and gentle vibrations to.",
      "attendees": 31,
      "isInterested": false,
      "hasVideo": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Upcoming Events', style: textTheme.titleLarge),
            IconButton(
              onPressed: () {},
              icon:
              const Icon(IconlyLight.search, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _events.length,
          itemBuilder: (context, index) => EventCard(event: _events[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          const SizedBox(height: 12),
          _buildPostBody(context),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 8),
          _buildPostFooter(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: textTheme.bodySmall,
                children: [
                  const TextSpan(text: 'Posted in '),
                  TextSpan(
                    text: post['community'],
                    style: const TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                if (context.mounted) {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: CommunityDetailScreen(),
                    withNavBar: false,
                  );
                }
              },
              child: Text(
                'View Community',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        // UPDATED: Divider color to match the lower one
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(height: 1, color: Colors.grey.shade200),
        ),
        Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(post['avatar'])),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post['name'],
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(post['time'], style: textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: AppColors.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildPostBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post['title'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              post['title'],
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        if (post['image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(post['image']),
          ),
        if (post['caption'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              post['caption'],
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        // UPDATED: Removed the border from the quote
        if (post['quote'] != null)
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              post['quote'],
              style: textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary.withOpacity(0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostFooter(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildFooterIcon(
              Icons.favorite,
              post['likes'].toString(),
              AppColors.primaryRed,
              AppColors.textSecondary,
            ),
            const SizedBox(width: 24),
            _buildFooterIcon(
              Iconsax.messages_2_copy,
              post['comments'].toString(),
              const Color(0xFF0A75BA),
              AppColors.textSecondary,
            ),
            const SizedBox(width: 24),
            _buildFooterIcon(
              Icons.share_outlined,
              post['shares'].toString(),
              const Color(0xFF009E60),
              AppColors.textSecondary,
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(
            IconlyLight.send,
            color: AppColors.textSecondary,
            size: 20,
          ),
          label: Text(
            'Comment',
            style: textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterIcon(
      IconData icon, String count, Color iconColor, Color color) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
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
