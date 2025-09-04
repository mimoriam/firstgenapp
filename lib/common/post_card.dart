import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/comments/comments_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/full_screen_image_viewer.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

/// A reusable widget to display a single post in a feed.
/// It's optimized for performance in lists.
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

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
          PostActions(post: post),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final viewModel = Provider.of<CommunityViewModel>(context, listen: false);

    // Using a StreamBuilder to get real-time updates for user data like name/avatar.
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firebaseService.getUserStream(post.authorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(height: 50); // Placeholder while loading
        }
        final authorData = snapshot.data?.data();
        final profileImageUrl = authorData?['profileImageUrl'];
        final postImageUrl = post.imageUrl;

        List<String> imageUrls = [];
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          imageUrls.add(profileImageUrl);
        }
        if (postImageUrl != null && postImageUrl.isNotEmpty) {
          imageUrls.add(postImageUrl);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.communityId != null)
              // This FutureBuilder fetches the community name for the post header.
              FutureBuilder<Community?>(
                future: firebaseService.getCommunityById(post.communityId!),
                builder: (context, communitySnapshot) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodySmall,
                          children: [
                            const TextSpan(text: 'Posted in '),
                            TextSpan(
                              text: communitySnapshot.data?.name ?? "...",
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
                          if (context.mounted &&
                              communitySnapshot.data != null) {
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: ChangeNotifierProvider.value(
                                value: viewModel,
                                child: CommunityDetailScreen(
                                  community: communitySnapshot.data!,
                                ),
                              ),
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
                  );
                },
              ),
            if (post.communityId != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (imageUrls.isNotEmpty) {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: FullScreenImageViewer(imageUrls: imageUrls),
                          withNavBar: false,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            authorData?['profileImageUrl'] ??
                                "https://randomuser.me/api/portraits/women/1.jpg",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorData?['fullName'] ?? "Author Name",
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                TimeAgo.format(
                                  post.timestamp.toDate().toIso8601String(),
                                ),
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'share') {
                      viewModel.sharePost(post.id);
                    }
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'share',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.share_outlined,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Share Post',
                                style: textTheme.labelLarge?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPostBody(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Get the screen width to calculate the cache size for the image.
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate a reasonable cache width based on screen size minus padding.
    final imageCacheWidth = (screenWidth - 48).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.imageUrl!,
              fit: BoxFit.cover,
              // *** PERFORMANCE OPTIMIZATION ***
              // Caching the image at a specific size reduces memory usage and improves scroll performance.
              cacheWidth: imageCacheWidth,
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.error_outline, color: Colors.red),
                ),
              ),
            ),
          )
        else
          Container(),
        if (post.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              post.content,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

/// A stateful widget to manage the actions (like, comment, share) for a post.
/// It uses optimistic updates for the like functionality for a snappier user experience.
class PostActions extends StatefulWidget {
  final Post post;

  const PostActions({super.key, required this.post});

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    final currentUserId = Provider.of<FirebaseService>(
      context,
      listen: false,
    ).currentUser?.uid;
    _isLiked = widget.post.likes[currentUserId] == true;
    _likeCount = widget.post.likes.length;
  }

  void _onComment() {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: CommentsScreen(postId: widget.post.id),
      withNavBar: false,
    );
  }

  void _onShare() {
    Provider.of<CommunityViewModel>(
      context,
      listen: false,
    ).sharePost(widget.post.id);
  }

  /// *** OPTIMISTIC UPDATE LOGIC ***
  /// Toggles the like status immediately in the UI and then sends the update to Firebase.
  void _toggleLike() {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser!.uid;

    // 1. Optimistically update the local state.
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });

    // 2. Send the update to the backend without waiting for it.
    firebaseService.togglePostLike(widget.post.id, userId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _toggleLike,
              child: _buildFooterIcon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                _likeCount.toString(),
                AppColors.primaryRed,
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _onComment,
              child: _buildFooterIcon(
                Iconsax.messages_2_copy,
                widget.post.commentCount.toString(),
                const Color(0xFF0A75BA),
                AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _onShare,
              child: _buildFooterIcon(
                Icons.share_outlined,
                "0", // Share count not in model yet
                const Color(0xFF009E60),
                AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _onComment,
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
