import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: AppColors.primaryBackground,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Reiki Healing Community',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              pinned: true,
              floating: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(220),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildHeaderCard(),
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryRed,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryRed,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
            _AboutTab(),
            _FeedTab(),
            _UpcomingEventsTab(), // UPDATED: Replaced placeholder
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80'),
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
              const Text(
                'Reiki Healing',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '4.3 (10K+ members)',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '"Reiki healing channels universal energy, restoring balance and promoting holistic well-being."',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Join Community', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedTab extends StatelessWidget {
  final List<Map<String, dynamic>> _posts = [
    {
      'name': 'Ariana',
      'avatar': 'https://randomuser.me/api/portraits/women/1.jpg',
      'time': '17 July at 08:02 AM',
      'community': 'Reiki Healing',
      'image': 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=500&q=80',
      'caption': 'My daughter just got diagnosed with ANOREXIA. Feeling overwhelmed. Any advice?',
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
      'quote': '"The whole secret of existence lies in the pursuit of meaning, purpose, and connection. It is a delicate dance between self-discovery, compassion for others, and embracing the ever-unfolding mysteries of life. Finding harmony in the ebb and flow of experiences, we unlock the profound beauty that resides within our shared journey."',
      'likes': 45,
      'comments': 12,
      'shares': 2,
    }
  ];

  @override
  Widget build(BuildContext context) {
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

  Widget _buildCreatePostSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good to see you again!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Here's a real-time view of what needs your attention today.",
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/75.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "What's on your mind? Ask a question or share your story.",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.photo_library_outlined, color: AppColors.textPrimary),
                    const SizedBox(width: 8),
                    const Icon(Icons.emoji_emotions_outlined, color: AppColors.textPrimary),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Text('Add your post in'),
                  label: const Icon(Icons.arrow_drop_down),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: GradientButton(
                  text: 'Post Now',
                  onPressed: () {},
                ),
              ),
            ],
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          const SizedBox(height: 12),
          _buildPostBody(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(height: 1, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 8),
          _buildPostFooter(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(post['avatar'])),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    post['time'],
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_horiz, color: AppColors.textSecondary),
          ],
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'DMSans'),
            children: [
              const TextSpan(text: 'Posted in '),
              TextSpan(
                text: post['community'],
                style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post['title'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              post['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        if (post['image'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(post['image']),
          ),
        if (post['caption'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(post['caption']),
          ),
        if (post['quote'] != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.primaryRed.withOpacity(0.5), width: 3),
              ),
            ),
            child: Text(
              post['quote'],
              style: const TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildFooterIcon(Icons.favorite, post['likes'].toString(), AppColors.primaryRed),
            const SizedBox(width: 24),
            _buildFooterIcon(Icons.chat_bubble_outline, post['comments'].toString(), AppColors.textSecondary),
            const SizedBox(width: 24),
            _buildFooterIcon(Icons.share_outlined, post['shares'].toString(), AppColors.textSecondary),
          ],
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.mode_comment_outlined, color: AppColors.textSecondary, size: 20),
          label: const Text('Comment', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFooterIcon(IconData icon, String count, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(count, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _AboutTab extends StatelessWidget {
  // UPDATED: Image URLs have been changed as requested.
  final List<String> _imageUrls = [
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome to Reiki Healing Community ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '👋', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A supportive space where practitioners and enthusiasts come together to explore the transformative power of Reiki, fostering growth, connection, and self-healing. Join us on this journey of wellness and inner harmony.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          _buildImageGrid(),
          const SizedBox(height: 24),
          _buildExpansionTile(
            title: 'What is this community for?',
            content: 'The expression or application of human creative skill and imagination, typically in a visual form such as painting or sculpture, producing works to be appreciated primarily for their beauty or emotional power.',
          ),
          const SizedBox(height: 8),
          _buildExpansionTile(
            title: 'What will you gain from this community?',
            content: 'The expression or application of human creative skill and imagination, typically in a visual form such as painting or sculpture, producing works to be appreciated primarily for their beauty or emotional power.',
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
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade200),
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
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

// NEW: Widget for the Upcoming Events Tab
class _UpcomingEventsTab extends StatelessWidget {
  final List<Map<String, dynamic>> _events = [
    {
      "image": "https://images.unsplash.com/photo-1540959733332-eab4de25247d?w=500&q=80",
      "title": "Diwali Cooking Workshop",
      "date": "8 December, 2025",
      "location": "Spice Garden Kitchen",
      "description": "Soothing audio and gentle vibrations to ease discomfort. Soothing audio and gentle vibrations to.",
      "attendees": 31,
      "isInterested": true,
      "hasVideo": false,
    },
    {
      "image": "https://images.unsplash.com/photo-1540959733332-eab4de25247d?w=500&q=80",
      "title": "Diwali Cooking Workshop",
      "date": "8 December, 2025",
      "location": "Spice Garden Kitchen",
      "description": "Soothing audio and gentle vibrations to ease discomfort. Soothing audio and gentle vibrations to.",
      "attendees": 31,
      "isInterested": false,
      "hasVideo": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _events.length,
          itemBuilder: (context, index) => _EventCard(event: _events[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        ),
      ],
    );
  }
}

class _EventCard extends StatefulWidget {
  final Map<String, dynamic> event;
  const _EventCard({required this.event});

  @override
  __EventCardState createState() => __EventCardState();
}

class __EventCardState extends State<_EventCard> {
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
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    widget.event['image'],
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  if (widget.event['hasVideo'] == true)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.event['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16.0,
              runSpacing: 8.0,
              children: [
                _buildInfoItem(
                  Icons.calendar_today,
                  widget.event['date'],
                  Colors.green.shade700,
                ),
                _buildInfoItem(
                  Icons.group_work,
                  widget.event['location'],
                  Colors.blue.shade700,
                ),
                _buildInfoItem(
                  Icons.people,
                  "${widget.event['attendees']} Attending",
                  Colors.orange.shade800,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              widget.event['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _isInterested
                      ? ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isInterested = false;
                      });
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text("I'm Interested"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackground,
                      foregroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )
                      : OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isInterested = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(color: AppColors.primaryRed),
                    ),
                    child: const Text(
                      "I'm Interested",
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.secondaryBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "View Community",
                      style: TextStyle(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
    return Container(
      color: AppColors.primaryBackground,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
