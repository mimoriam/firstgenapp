import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_detail/community_detail_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class AllCommunitiesScreen extends StatefulWidget {
  const AllCommunitiesScreen({super.key});

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Community> _communities = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getCommunities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getCommunities();
      }
    });
  }

  Future<void> _getCommunities() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final newCommunities = await firebaseService.getAllCommunities(
      startAfter: _lastDocument,
      searchQuery: _searchQuery.toLowerCase(),
    );

    if (newCommunities.isEmpty) {
      setState(() {
        _hasMore = false;
      });
    } else {
      _lastDocument = newCommunities.last.originalDoc;
      setState(() {
        _communities.addAll(newCommunities);
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _communities = [];
        _lastDocument = null;
        _hasMore = true;
      });
      _getCommunities();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
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
        title: RichText(
          text: TextSpan(
            style: textTheme.headlineSmall,
            children: [
              const TextSpan(text: 'All Communities: '),
              TextSpan(
                text: _communities.length.toString(),
                style: textTheme.headlineSmall?.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _communities.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _communities.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _CommunityCard(community: _communities[index]);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Community community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser?.uid;
    final isMember = community.members.contains(userId);
    final isCreator = community.creatorId == userId;

    return SizedBox(
      height: 170,
      child: GestureDetector(
        onTap: () {
          PersistentNavBarNavigator.pushNewScreen(
            context,
            screen: ChangeNotifierProvider.value(
              value: Provider.of<CommunityViewModel>(context, listen: false),
              child: CommunityDetailScreen(community: community),
            ),
            withNavBar: false,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                community.imageUrl,
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
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
                            '${community.members.length} members',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        community.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: isMember || isCreator
                            ? null
                            : () {
                                final viewModel =
                                    Provider.of<CommunityViewModel>(
                                      context,
                                      listen: false,
                                    );
                                firebaseService
                                    .joinCommunity(community.id, userId!)
                                    .then((_) => viewModel.refreshAllData());
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          textStyle: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        child: Text(
                          isMember || isCreator ? 'Joined' : 'Join Community',
                        ),
                      ),
                    ],
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
