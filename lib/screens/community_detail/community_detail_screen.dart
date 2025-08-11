import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CommunityDetailScreen extends StatefulWidget {
  const CommunityDetailScreen({super.key});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen>
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
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
              title: Text(
                'Reiki Healing Community',
                style: textTheme.titleLarge,
              ),
              pinned: true,
              floating: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(220),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _buildHeaderCard(),
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
          children: [_AboutTab(), _FeedTab(), _UpcomingEventsTab()],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.4),
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
                'Reiki Healing',
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '4.3 (10K+ members)',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"Reiki healing channels universal energy, restoring balance and promoting holistic well-being."',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Join Community',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
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

//** =============================== FEED TAB =============================== **//

class _FeedTab extends StatelessWidget {
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
    return ListView.separated(
      padding: const EdgeInsets.only(top: 16, left: 12, right: 12, bottom: 16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _PostCard(post: _posts[index]);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
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
                // No action needed here as we are already in the detail screen
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
      IconData icon,
      String count,
      Color iconColor,
      Color color,
      ) {
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

//** =============================== ABOUT TAB =============================== **//

class _AboutTab extends StatelessWidget {
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
  ];

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
                  text: 'Welcome to Reiki Healing Community ',
                  style: textTheme.titleLarge,
                ),
                const TextSpan(text: '👋', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A supportive space where practitioners and enthusiasts come together to explore the transformative power of Reiki, fostering growth, connection, and self-healing. Join us on this journey of wellness and inner harmony.',
            style: textTheme.bodySmall?.copyWith(height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildImageGrid(),
          const SizedBox(height: 24),
          _buildExpansionTile(
            title: 'What is this community for?',
            content:
            'The expression or application of human creative skill and imagination, typically in a visual form such as painting or sculpture, producing works to be appreciated primarily for their beauty or emotional power.',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            title: 'What will you gain from this community?',
            content:
            'The expression or application of human creative skill and imagination, typically in a visual form such as painting or sculpture, producing works to be appreciated primarily for their beauty or emotional power.',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            title: 'Community Rules',
            content: '1. Be respectful. 2. No spam. 3. Share with kindness.',
            isInitiallyExpanded: false,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            _imageUrls[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey.shade200),
          ),
        );
      },
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
        initiallyExpanded: isInitiallyExpanded,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        tilePadding: EdgeInsets.zero,
        children: [
          Text(
            content,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

//** =============================== UPCOMING EVENTS TAB =============================== **//

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

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _events.length,
      itemBuilder: (context, index) =>
          EventCard(event: _events[index], copied: true),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
    );
  }
}

//** =============================== SLIVER APP BAR DELEGATE =============================== **//

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
