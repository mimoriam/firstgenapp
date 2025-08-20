import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

/// A view model to hold and manage the current user's profile data.
///
/// This provider acts as a centralized cache for the user's profile,
/// allowing different parts of the app to access the data without
/// needing to fetch it from Firebase every time.
class UserProfileViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;
  Map<String, dynamic>? _userProfileData;

  /// The user's profile data as a map.
  Map<String, dynamic>? get userProfileData => _userProfileData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserProfileViewModel(this._firebaseService);

  /// Fetches the user profile from Firebase and notifies listeners.
  Future<void> fetchUserProfile() async {
    _isLoading = true;
    // Notify listeners at the start of the fetch operation.
    notifyListeners();
    final snapshot = await _firebaseService.getUserProfile();
    _userProfileData = snapshot?.data();
    _isLoading = false;
    // Notify listeners again once the data is available.
    notifyListeners();
  }

  /// Clears the cached user profile data.
  void clearProfile() {
    _userProfileData = null;
    notifyListeners();
  }

  /// Refreshes the user profile data from Firebase.
  Future<void> refreshUserProfile() async {
    await fetchUserProfile();
  }

  /// Updates the local profile data and notifies listeners for instant UI updates.
  /// This makes the UI feel responsive while the data is being saved to Firebase
  /// in the background.
  void updateLocalProfileData(Map<String, dynamic> newData) {
    if (_userProfileData != null) {
      _userProfileData!.addAll(newData);
      notifyListeners();
    }
  }
}
