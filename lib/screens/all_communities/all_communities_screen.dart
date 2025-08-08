import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({super.key});

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  // Mock data for all communities
  final List<Map<String, dynamic>> _communities = [
    {
      'name': 'Reiki Healing',
      'rating': 4.3,
      'members': '10K+',
      'description':
      'Reiki healing channels universal energy, restoring balance and promoting holistic well-being.',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
    },
    {
      'name': 'Yoga & Meditation',
      'rating': 4.8,
      'members': '25K+',
      'description': 'Find your inner peace and strength through the practice of yoga and meditation.',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
    },
    {
      'name': 'Spiritual Awakening',
      'rating': 4.5,
      'members': '15K+',
      'description':
      'Explore your spiritual path and connect with like-minded individuals on their journey.',
      'image': 'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=500&q=80',
    },
    {
      'name': 'Holistic Health',
      'rating': 4.6,
      'members': '18K+',
      'description':
      'A community dedicated to natural and holistic approaches to health and wellness.',
      'image': 'https://images.unsplash.com/photo-1552083375-1447ce886485?w=500&q=80',
    },
    {
      'name': 'Mindfulness Practices',
      'rating': 4.7,
      'members': '22K+',
      'description':
      'Learn and share mindfulness techniques to live a more present and fulfilling life.',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500&q=80',
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
        title: RichText(
          text: TextSpan(
            // UPDATED: Inherited from theme
            style: textTheme.headlineSmall,
            children: [
              const TextSpan(text: 'All Communities: '),
              TextSpan(
                text: _communities.length.toString(),
                // UPDATED: Inherited from theme
                style: textTheme.headlineSmall?.copyWith(color: AppColors.primaryRed),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _communities.length,
        itemBuilder: (context, index) {
          return _CommunityCard(community: _communities[index]);
        },
        // UPDATED: Reduced spacing
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Map<String, dynamic> community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      // UPDATED: Reduced height for compactness
      height: 170,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              community['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey.shade300),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                // UPDATED: Reduced padding
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community['name'],
                      // UPDATED: Inherited from theme and size adjusted
                      style: textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${community['rating']} (${community['members']} members)',
                          // UPDATED: Font size reduced
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      community['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall
                          ?.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // UPDATED: Compacted button padding
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        // UPDATED: Compacted button text style
                        textStyle: textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      child: const Text('Join Community'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}