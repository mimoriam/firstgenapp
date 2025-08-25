import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class CommunityViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  final String _userId;

  CommunityViewModel(this._firebaseService, this._userId) {
    _fetchInitialData();
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

  void _fetchInitialData() {
    fetchAllCommunities(isInitial: true);
    fetchMyFeed(isInitial: true);
    fetchMyCommunities();
  }

  Future<void> fetchAllCommunities({bool isInitial = false}) async {
    if (_isLoadingAll || !_hasMoreAll) return;
    _isLoadingAll = true;
    if (isInitial) {
      _allCommunities = [];
      _lastAllCommunityDoc = null;
      _hasMoreAll = true;
    }
    notifyListeners();

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
      notifyListeners();
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
    notifyListeners();

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
      notifyListeners();
    }
  }

  Future<void> fetchMyCommunities() async {
    _isLoadingMyCommunities = true;
    notifyListeners();
    try {
      _createdCommunities = await _firebaseService.getCreatedCommunities(
        _userId,
      );
      _joinedCommunities = await _firebaseService.getJoinedCommunities(_userId);
    } catch (e) {
      // Handle error
    } finally {
      _isLoadingMyCommunities = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String content,
    String? communityId,
    File? image,
  }) async {
    try {
      await _firebaseService.createPost(
        content: content,
        authorId: _userId,
        communityId: communityId,
        image: image,
      );
      fetchMyFeed(isInitial: true); // Refresh feed
    } catch (e) {
      // Handle error
    }
  }
}
