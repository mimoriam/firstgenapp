import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firstgenapp/common/gradient_btn.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/all_communities/all_communities_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/comments/comments_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/create_community/create_community_screen.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconly/iconly.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class CommunityScreen extends StatefulWidget {
  final int? initialIndex;
  const CommunityScreen({super.key, this.initialIndex});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex ?? 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    final viewModel = Provider.of<CommunityViewModel>(context, listen: false);
    await viewModel.refreshAllData();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
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
              Text(
                'Culture starts with connection',
                style: textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                if (context.mounted) {
                  final viewModel = Provider.of<CommunityViewModel>(
                    context,
                    listen: false,
                  );
                  // Await the result of the navigation to refresh data
                  await PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: ChangeNotifierProvider.value(
                      value: viewModel,
                      child: const CreateCommunityScreen(),
                    ),
                    withNavBar: false,
                  );
                  // Refresh data after returning from CreateCommunityScreen
                  await viewModel.refreshAllData();
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
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _AllCommunitiesSection()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _CreatePostSection(),
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
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
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
              children: [
                _MyFeedTab(),
                _MyCommunitiesTab(),
                _UpcomingEventsTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AllCommunitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Use Consumer here to automatically rebuild when data changes
    return Consumer<CommunityViewModel>(
      builder: (context, viewModel, child) {
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
                            screen: ChangeNotifierProvider.value(
                              value: viewModel,
                              child: const AllCommunitiesScreen(),
                            ),
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
              const SizedBox(height: 2),
              SizedBox(
                height: 90,
                child: Builder(
                  builder: (context) {
                    if (viewModel.allCommunities.isEmpty &&
                        viewModel.isLoadingAll) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (viewModel.allCommunities.isEmpty) {
                      return const Center(child: Text("No communities found."));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: viewModel.allCommunities.length,
                      itemBuilder: (context, index) {
                        final community = viewModel.allCommunities[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              if (context.mounted) {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: ChangeNotifierProvider.value(
                                    value: viewModel,
                                    child: CommunityDetailScreen(
                                      community: community,
                                    ),
                                  ),
                                  withNavBar: false,
                                );
                              }
                            },
                            child: SizedBox(
                              width: 70,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: NetworkImage(
                                      community.imageUrl,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    community.name,
                                    style: textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyFeedTab extends StatefulWidget {
  @override
  __MyFeedTabState createState() => __MyFeedTabState();
}

class __MyFeedTabState extends State<_MyFeedTab> {
  late Stream<List<Post>> _feedStream;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser?.uid;
    if (userId != null) {
      _feedStream = firebaseService.getFeedStreamForUser(userId);
    } else {
      _feedStream = Stream.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _feedStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Your feed is empty."));
        }
        final posts = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _PostCard(key: ValueKey(post.id), post: post);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
        );
      },
    );
  }
}

class _CreatePostSection extends StatefulWidget {
  @override
  __CreatePostSectionState createState() => __CreatePostSectionState();
}

class __CreatePostSectionState extends State<_CreatePostSection> {
  final _formKey = GlobalKey<FormBuilderState>();
  File? _image;
  String? _selectedCommunityId;
  bool _isPosting = false;
  final _postContentController = TextEditingController();
  bool _emojiShowing = false;
  String? _link;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _postContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = Provider.of<CommunityViewModel>(context, listen: false);

    final postContentField = _formKey.currentState?.fields['post_content'];
    final hasError = postContentField?.hasError ?? false;

    return FormBuilder(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasError
                              ? Theme.of(context).colorScheme.error
                              : Colors.grey.shade200,
                          width: hasError ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: 'post_content',
                            controller: _postContentController,
                            maxLines: 5,
                            minLines: 1,
                            validator: (value) {
                              if ((value == null || value.isEmpty) &&
                                  _image == null) {
                                return 'Please write something or add an image.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  "What's on your mind? Ask a question or share your story..",
                              hintStyle: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(12),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 12.0,
                              bottom: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: _pickImage,
                                  icon: const Icon(
                                    IconlyLight.camera,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _emojiShowing = !_emojiShowing;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: AppColors.textSecondary,
                                    size: 21,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 52.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _image!,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _image = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                const Icon(
                  Iconsax.global_copy,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                DropdownButton<String>(
                  value: _selectedCommunityId,
                  hint: Text('Post to...', style: textTheme.labelLarge),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('My Feed')),
                    ...viewModel.joinedCommunities.map((community) {
                      return DropdownMenuItem(
                        value: community.id,
                        child: SizedBox(
                          width: 100,
                          child: Text(
                            community.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                    ...viewModel.createdCommunities.map((community) {
                      return DropdownMenuItem(
                        value: community.id,
                        child: SizedBox(
                          width: 100,
                          child: Text(
                            community.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCommunityId = value;
                    });
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isPosting
                      ? null
                      : () {
                          if (_formKey.currentState?.saveAndValidate() ??
                              false) {
                            setState(() {
                              _isPosting = true;
                            });
                            final postContent =
                                _formKey.currentState?.value['post_content'] ??
                                '';
                            viewModel
                                .createPost(
                                  content: postContent,
                                  communityId: _selectedCommunityId,
                                  image: _image,
                                  link: _link,
                                  emojis: _postContentController.text.characters
                                      .where(
                                        (char) => char.contains(
                                          RegExp(
                                            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
                                          ),
                                        ),
                                      )
                                      .toList(),
                                )
                                .then((_) {
                                  _formKey.currentState?.reset();
                                  setState(() {
                                    _image = null;
                                    _isPosting = false;
                                    _link = null;
                                  });
                                  if (context.mounted) {
                                    FocusScope.of(context).unfocus();
                                  }
                                });
                          }
                        },
                  icon: _isPosting
                      ? Container(
                          width: 20,
                          height: 20,
                          padding: const EdgeInsets.all(2.0),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(IconlyLight.send, size: 18),
                  label: _isPosting
                      ? const SizedBox.shrink()
                      : const Text('Post Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Offstage(
            offstage: !_emojiShowing,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _postContentController,
                onBackspacePressed: () {
                  // Do something when the user taps the backspace button (optional)
                },
                config: const Config(
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32 * 1.0,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileViewModel>(
      builder: (context, userProfileViewModel, child) {
        final userData = userProfileViewModel.userProfileData;
        final imageUrl = userData?['profileImageUrl'];
        final hasPhoto = imageUrl != null && imageUrl.isNotEmpty;

        return CircleAvatar(
          radius: 20,
          backgroundImage: hasPhoto ? NetworkImage(imageUrl) : null,
          child: !hasPhoto
              ? const Icon(
                  IconlyLight.profile,
                  size: 20,
                  color: AppColors.textSecondary,
                )
              : null,
        );
      },
    );
  }
}

class _MyCommunitiesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingMyCommunities) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSectionTitle('Communities I Created', context),
            const SizedBox(height: 12),
            if (viewModel.createdCommunities.isEmpty)
              const Text("You haven't created any communities yet.")
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: viewModel.createdCommunities.length,
                itemBuilder: (context, index) => _CommunityListCard(
                  community: viewModel.createdCommunities[index],
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('Communities I Joined', context),
            const SizedBox(height: 12),
            if (viewModel.joinedCommunities.isEmpty)
              const Text("You haven't joined any communities yet.")
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: viewModel.joinedCommunities.length,
                itemBuilder: (context, index) => _CommunityListCard(
                  community: viewModel.joinedCommunities[index],
                ),
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

class _CommunityListCard extends StatelessWidget {
  final Community community;

  const _CommunityListCard({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final viewModel = Provider.of<CommunityViewModel>(context, listen: false);

    return SizedBox(
      height: 140,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              community.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withAlpha(178),
                    Colors.black.withAlpha(102),
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
                    community.name,
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
                        '${community.members.length} members',
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
                          screen: ChangeNotifierProvider.value(
                            value: viewModel,
                            child: CommunityDetailScreen(community: community),
                          ),
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
  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoadingEvents) {
          return const Center(child: CircularProgressIndicator());
        }
        if (viewModel.upcomingEvents.isEmpty) {
          return const Center(child: Text("You have no upcoming events."));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: viewModel.upcomingEvents.length,
          itemBuilder: (context, index) =>
              EventCard(event: viewModel.upcomingEvents[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({super.key, required this.post});

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
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final viewModel = Provider.of<CommunityViewModel>(context, listen: false);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: firebaseService.getUserStream(post.authorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink(); // Or a loading indicator
        }
        final authorData = snapshot.data?.data();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.communityId != null)
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'share') {
                      viewModel.sharePost(post.id);
                    } else if (value == 'hide') {
                      debugPrint('Hide post tapped');
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.imageUrl!,
              fit: BoxFit.cover,
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

  Widget _buildPostFooter(BuildContext context) {
    return _PostActions(post: post);
  }
}

class _PostActions extends StatefulWidget {
  final Post post;

  const _PostActions({required this.post});

  @override
  __PostActionsState createState() => __PostActionsState();
}

class __PostActionsState extends State<_PostActions> {
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

  void _toggleLike() {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser!.uid;
    firebaseService.togglePostLike(widget.post.id, userId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final currentUserId = firebaseService.currentUser?.uid;
    final isLiked = widget.post.likes[currentUserId] == true;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _toggleLike,
              child: _buildFooterIcon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                widget.post.likes.length.toString(),
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
