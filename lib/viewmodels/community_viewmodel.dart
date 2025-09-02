import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CommunityViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final String _userId;

  // Add a subscription variable to manage the stream listener
  StreamSubscription? _eventsSubscription;
  // Add a flag to check if the view model has been disposed
  bool _isDisposed = false;

  CommunityViewModel(this._firebaseService, this._userId) {
    _fetchInitialData();
  }

  // Override dispose to cancel subscriptions and set the flag
  @override
  void dispose() {
    _isDisposed = true;
    _eventsSubscription?.cancel();
    super.dispose();
  }

  // Helper to safely call notifyListeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // All Communities
  List<Community> _allCommunities = [];
  List<Community> get allCommunities => _allCommunities;
  DocumentSnapshot? _lastAllCommunityDoc;
  bool _isLoadingAll = false;
  bool get isLoadingAll => _isLoadingAll;
  bool _hasMoreAll = true;

  // My Feed
  List<Post> _feedPosts = [];
  List<Post> get feedPosts => _feedPosts;
  DocumentSnapshot? _lastFeedPostDoc;
  bool _isLoadingFeed = false;
  bool _hasMoreFeed = true;

  // My Communities
  List<Community> _createdCommunities = [];
  List<Community> get createdCommunities => _createdCommunities;
  List<Community> _joinedCommunities = [];
  List<Community> get joinedCommunities => _joinedCommunities;
  bool _isLoadingMyCommunities = false;
  bool get isLoadingMyCommunities => _isLoadingMyCommunities;

  // Upcoming Events
  List<Event> _upcomingEvents = [];
  List<Event> get upcomingEvents => _upcomingEvents;
  bool _isLoadingEvents = false;
  bool get isLoadingEvents => _isLoadingEvents;

  void _fetchInitialData() {
    fetchAllCommunities(isInitial: true);
    fetchMyFeed(isInitial: true);
    fetchMyCommunities();
    fetchUpcomingEvents();
  }

  Future<void> refreshAllData() async {
    // Cancel existing subscription before fetching new data to avoid duplicates.
    await _eventsSubscription?.cancel();

    await Future.wait([
      fetchAllCommunities(isInitial: true),
      fetchMyFeed(isInitial: true),
      fetchMyCommunities(),
      fetchUpcomingEvents(),
    ]);
    _safeNotifyListeners();
  }

  Future<void> fetchUpcomingEvents() async {
    _isLoadingEvents = true;
    _safeNotifyListeners();
    try {
      // Assign the subscription to the variable so it can be cancelled later.
      _eventsSubscription = _firebaseService
          .getInterestedEventsForUser(_userId)
          .listen((events) {
            _upcomingEvents = events;
            _isLoadingEvents = false;
            _safeNotifyListeners();
          });
    } catch (e) {
      // Handle error
      _isLoadingEvents = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchAllCommunities({bool isInitial = false}) async {
    if (_isLoadingAll || !_hasMoreAll) return;
    _isLoadingAll = true;
    if (isInitial) {
      _allCommunities = [];
      _lastAllCommunityDoc = null;
      _hasMoreAll = true;
    }
    _safeNotifyListeners();

    try {
      final newCommunities = await _firebaseService.getAllCommunities(
        startAfter: _lastAllCommunityDoc,
      );
      if (newCommunities.isEmpty) {
        _hasMoreAll = false;
      } else {
        _lastAllCommunityDoc = newCommunities.last.originalDoc;
        _allCommunities.addAll(newCommunities);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoadingAll = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchMyFeed({bool isInitial = false}) async {
    if (_isLoadingFeed || !_hasMoreFeed) return;
    _isLoadingFeed = true;
    if (isInitial) {
      _feedPosts = [];
      _lastFeedPostDoc = null;
      _hasMoreFeed = true;
    }
    _safeNotifyListeners();

    try {
      final newPosts = await _firebaseService.getFeedForUser(
        _userId,
        startAfter: _lastFeedPostDoc,
      );
      if (newPosts.isEmpty) {
        _hasMoreFeed = false;
      } else {
        _lastFeedPostDoc = newPosts.last.originalDoc;
        _feedPosts.addAll(newPosts);
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoadingFeed = false;
      _safeNotifyListeners();
    }
  }

  Future<void> fetchMyCommunities() async {
    _isLoadingMyCommunities = true;
    _safeNotifyListeners();
    try {
      _createdCommunities = await _firebaseService.getCreatedCommunities(
        _userId,
      );
      _joinedCommunities = await _firebaseService.getJoinedCommunities(_userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoadingMyCommunities = false;
      _safeNotifyListeners();
    }
  }

  Future<void> createPost({
    required String content,
    String? communityId,
    File? image,
    String? link,
    List<String>? emojis,
  }) async {
    try {
      await _firebaseService.createPost(
        content: content,
        authorId: _userId,
        communityId: communityId,
        image: image,
        link: link,
        emojis: emojis,
      );
      await fetchMyFeed(isInitial: true); // Refresh feed after posting
    } catch (e) {
      // Handle error
    }
  }

  Future<void> togglePostLike(String postId) async {
    await _firebaseService.togglePostLike(postId, _userId);
    // No need to refresh the whole feed, the local state will update
    // fetchMyFeed(isInitial: true);
    _safeNotifyListeners();
  }

  Future<void> sharePost(String postId) async {
    // Implement sharing logic, e.g., using the `share_plus` package
    final post = _feedPosts.firstWhere((p) => p.id == postId);
    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      SharePlus.instance.share(
        ShareParams(
          text: post.imageUrl,
          title: post.content,
          subject: 'Check out this post from First Gen!',
        ),
      );
    } else {
      SharePlus.instance.share(
        ShareParams(
          title: 'Check out this post from First Gen!',
          text: post.content,
        ),
      );
    }
    // Share.share(post.content, subject: 'Check out this post from First Gen!');
  }
}
