import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

// Enum to represent the different authentication states.
enum AuthStatus {
  uninitialized,
  unauthenticated,
  // MODIFICATION: Added a new state to handle the period after login but before the profile check is complete.
  authenticating,
  authenticated_incomplete_profile,
  authenticated_complete_profile,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService;
  late StreamSubscription<User?> _authSubscription;

  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;

  User? _user;
  User? get user => _user;

  AuthProvider(this._firebaseService) {
    // Listen to Firebase auth state changes as soon as the provider is created.
    _authSubscription = _firebaseService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      _user = user;
      // MODIFICATION: Immediately set status to authenticating to show a loading indicator
      // and prevent the sign-in screen from flashing.
      _status = AuthStatus.authenticating;
      notifyListeners(); // Notify listeners to show the loading screen.

      // When a user is logged in, check if their profile is complete.
      final bool isProfileComplete = await _firebaseService
          .isUserProfileComplete(user.uid);
      if (isProfileComplete) {
        _status = AuthStatus.authenticated_complete_profile;
      } else {
        _status = AuthStatus.authenticated_incomplete_profile;
      }
    }
    // Notify all listening widgets that the final state has been determined.
    notifyListeners();
  }

  Future<void> recheckUserProfile() async {
    if (_user != null) {
      // Set status to authenticating to show a brief loading indicator
      // and prevent UI flicker.
      _status = AuthStatus.authenticating;
      notifyListeners();

      final bool isProfileComplete = await _firebaseService
          .isUserProfileComplete(_user!.uid);

      if (isProfileComplete) {
        _status = AuthStatus.authenticated_complete_profile;
      } else {
        _status = AuthStatus.authenticated_incomplete_profile;
      }
      // Notify listeners with the final, correct state.
      notifyListeners();
    }
  }
}
