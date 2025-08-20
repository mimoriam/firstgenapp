import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

/// A view model to hold and manage the current user's profile data.
///
/// This provider acts as a centralized cache for the user's profile,
/// allowing different parts of the app to access the data without
/// needing to fetch it from Firebase every time.
class UserProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  DocumentSnapshot<Map<String, dynamic>>? _userProfile;

  /// The user's profile document snapshot.
  DocumentSnapshot<Map<String, dynamic>>? get userProfile => _userProfile;

  /// The user's profile data as a map.
  Map<String, dynamic>? get userProfileData => _userProfile?.data();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfileViewModel(this._firebaseService);

  /// Fetches the user profile from Firebase and notifies listeners.
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();
    _userProfile = await _firebaseService.getUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  /// Clears the cached user profile data.
  void clearProfile() {
    _userProfile = null;
    notifyListeners();
  }

  /// Refreshes the user profile data from Firebase.
  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
  }
}
