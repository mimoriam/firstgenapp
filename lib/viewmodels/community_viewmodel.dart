import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:rxdart/rxdart.dart';

class CommunityViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final String _userId;

  // --- START PERFORMANCE & REAL-TIME FIX ---
  // A cache to hold active user streams. This prevents creating duplicate listeners
  // for the same user, solving both performance lag and stale data issues.
  final Map<String, Stream<DocumentSnapshot<Map<String, dynamic>>>>
  _userStreamCache = {};
  // --- END PERFORMANCE & REAL-TIME FIX ---

  StreamSubscription? _eventsSubscription;
  bool _isDisposed = false;

  CommunityViewModel(this._firebaseService, this._userId) {
    _fetchInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _eventsSubscription?.cancel();
    _userStreamCache.clear();
    super.dispose();
  }

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
    await _eventsSubscription?.cancel();
    _userStreamCache.clear(); // Clear stream cache on refresh

    await Future.wait([
      fetchAllCommunities(isInitial: true),
      fetchMyFeed(isInitial: true),
      fetchMyCommunities(),
      fetchUpcomingEvents(),
    ]);
    _safeNotifyListeners();
  }

  // --- START PERFORMANCE & REAL-TIME FIX ---
  /// Provides a stream for a user's profile.
  /// It creates a new stream if one doesn't exist for the user ID,
  /// otherwise returns the cached stream. This ensures only one listener
  /// per user is active at any time.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String userId) {
    if (!_userStreamCache.containsKey(userId)) {
      _userStreamCache[userId] = _firebaseService
          .getUserStream(userId)
          .shareReplay(maxSize: 1);
    }
    return _userStreamCache[userId]!;
  }
  // --- END PERFORMANCE & REAL-TIME FIX ---

  Future<void> fetchUpcomingEvents() async {
    _isLoadingEvents = true;
    _safeNotifyListeners();
    try {
      _eventsSubscription = _firebaseService
          .getInterestedEventsForUser(_userId)
          .listen((events) {
            _upcomingEvents = events;
            _isLoadingEvents = false;
            _safeNotifyListeners();
          });
    } catch (e) {
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
      await fetchMyFeed(isInitial: true);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> sharePost(String postId) async {
    final post = _feedPosts.firstWhere(
      (p) => p.id == postId,
      orElse: () {
        return Post(
          id: 'not-found',
          authorId: '',
          content: 'Check out this post!',
          timestamp: Timestamp.now(),
          likes: {},
          commentCount: 0,
          originalDoc: MockDocumentSnapshot(),
        );
      },
    );

    if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
      Share.share(
        'Check out this post from First Gen!\n\n${post.content}\n\n${post.imageUrl}',
      );
    } else {
      Share.share('Check out this post from First Gen!\n\n${post.content}');
    }
  }
}

class MockDocumentSnapshot implements DocumentSnapshot {
  @override
  dynamic get(Object field) => null;

  @override
  dynamic operator [](Object field) => null;

  @override
  String get id => 'mock';
  @override
  Map<String, dynamic>? data() => {};
  @override
  bool get exists => false;
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  DocumentReference<Object?> get reference => throw UnimplementedError();
}
