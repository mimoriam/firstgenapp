// ignore_for_file: file_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/services/continent_service.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  final FirebaseService _firebaseService;

  SignUpViewModel(this._firebaseService);

  // Step 1: Basic Info
  String? fullName;
  String? email;
  String? password;

  // Step 2: Cultural Background
  String? culturalHeritage;
  List<String> languages = [];
  String? generation;

  // Step 3: Religion & Spirituality
  String? religion;
  double religionImportance = 0.5;

  // Step 4: Family & Traditions
  double familyImportance = 0.5;
  List<String> traditions = [];

  // Step 5: Food & Lifestyle
  String? cuisines;
  List<String> dietaryPreferences = [];

  // Step 6: Music & Arts
  String? music;
  List<String> arts = [];

  // Step 7: Values & Beliefs
  List<String> coreValues = [];

  // Step 8: Hobbies & Interest
  String? hobbies;
  List<String> sports = [];

  // Step 9: What you are Looking For
  String? relationshipSeeking;
  double partnerCulturalBackgroundImportance = 0.5;
  String? dealBreakers;

  // Step 10: Profile Setup
  File? profileImage;
  String? bio;
  String? gender;
  DateTime? dateOfBirth;
  String? profession;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Updates the data from the first step of the sign-up process.
  void updateStep1({
    required String fullName,
    required String email,
    required String password,
  }) {
    this.fullName = fullName;
    this.email = email;
    this.password = password;
    notifyListeners();
  }

  /// Populates basic info from a Firebase User object.
  void populateFromUser(User user) {
    fullName = user.displayName ?? fullName;
    email = user.email;
    password = null;
    notifyListeners();
  }

  /// Updates the data from the subsequent steps.
  void updateData(Map<String, dynamic> data) {
    if (data.containsKey('cultural_heritage')) {
      culturalHeritage = data['cultural_heritage'];
    }
    if (data.containsKey('languages')) {
      languages = List<String>.from(data['languages']);
    }
    if (data.containsKey('generation')) generation = data['generation'];
    if (data.containsKey('religion')) religion = data['religion'];
    if (data.containsKey('religion_importance')) {
      religionImportance = data['religion_importance'];
    }
    if (data.containsKey('family_importance')) {
      familyImportance = data['family_importance'];
    }
    if (data.containsKey('traditions')) {
      traditions = List<String>.from(data['traditions']);
    }
    if (data.containsKey('cuisines')) cuisines = data['cuisines'];
    if (data.containsKey('dietary_preferences')) {
      dietaryPreferences = List<String>.from(data['dietary_preferences']);
    }
    if (data.containsKey('music')) music = data['music'];
    if (data.containsKey('arts')) arts = List<String>.from(data['arts']);
    if (data.containsKey('core_values')) {
      coreValues = List<String>.from(data['core_values']);
    }
    if (data.containsKey('hobbies')) hobbies = data['hobbies'];
    if (data.containsKey('sports')) sports = List<String>.from(data['sports']);
    if (data.containsKey('relationship_seeking')) {
      relationshipSeeking = data['relationship_seeking'];
    }
    if (data.containsKey('partner_cultural_background_importance')) {
      partnerCulturalBackgroundImportance =
          data['partner_cultural_background_importance'];
    }
    if (data.containsKey('deal_breakers')) dealBreakers = data['deal_breakers'];
    if (data.containsKey('profile_image')) profileImage = data['profile_image'];
    if (data.containsKey('bio')) bio = data['bio'];
    if (data.containsKey('gender')) gender = data['gender'];
    if (data.containsKey('dob')) dateOfBirth = data['dob'];
    if (data.containsKey('profession')) profession = data['profession'];

    notifyListeners();
  }

  /// Gathers all data from the view model and saves it to Firestore.
  Future<void> completeRegistration() async {
    if (email == null) {
      throw Exception("User basic info is not available.");
    }

    _setLoading(true);

    try {
      User? user = _firebaseService.currentUser;

      if (password != null) {
        UserCredential userCredential = await _firebaseService.signUpWithEmail(
          email: email!,
          password: password!,
          fullName: fullName!,
        );
        user = userCredential.user;
      }

      if (user == null) {
        throw Exception("User is not signed in. Cannot complete registration.");
      }

      // FIX: Prioritize fullName from the ViewModel, but fallback to the user's displayName.
      final finalFullName = fullName ?? user.displayName;

      if (finalFullName == null || finalFullName.isEmpty) {
        throw Exception("User's full name is not available.");
      }

      // Ensure the auth profile is up-to-date.
      if (user.displayName != finalFullName) {
        await user.updateDisplayName(finalFullName);
      }

      String? imageUrl;
      if (profileImage != null) {
        imageUrl = await _firebaseService.uploadProfileImage(
          user.uid,
          profileImage!,
        );
      }

      final String continent = culturalHeritage != null
          ? ContinentService.getContinent(culturalHeritage!)
          : 'Unknown';

      final Map<String, dynamic> userProfileData = {
        'uid': user.uid,
        'fullName': finalFullName,
        'email': email,
        'profileImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'culturalHeritage': culturalHeritage,
        'continent': continent,
        'languages': languages,
        'generation': generation,
        'religion': religion,
        'religionImportance': religionImportance,
        'familyImportance': familyImportance,
        'traditions': traditions,
        'cuisines': cuisines,
        'dietaryPreferences': dietaryPreferences,
        'music': music,
        'arts': arts,
        'coreValues': coreValues,
        'hobbies': hobbies,
        'sports': sports,
        'relationshipSeeking': relationshipSeeking,
        'partnerCulturalBackgroundImportance':
            partnerCulturalBackgroundImportance,
        'dealBreakers': dealBreakers,
        'bio': bio,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'profession': profession,
        'lookingForGeneration': 'First generation',
        'regionFocus': 'Global',
        'seeProfile': 'Everyone',
        'appNotificationsEnabled': true,
        'eventRemindersEnabled': true,
        'showJoinedCommunities': true,
      };

      userProfileData.removeWhere((key, value) => value == null);

      await _firebaseService.createUserDocument(user.uid, userProfileData);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void reset() {
    fullName = null;
    email = null;
    password = null;
    culturalHeritage = null;
    languages = [];
    generation = null;
    religion = null;
    religionImportance = 0.5;
    familyImportance = 0.5;
    traditions = [];
    cuisines = null;
    dietaryPreferences = [];
    music = null;
    arts = [];
    coreValues = [];
    hobbies = null;
    sports = [];
    relationshipSeeking = null;
    partnerCulturalBackgroundImportance = 0.5;
    dealBreakers = null;
    profileImage = null;
    bio = null;
    gender = null;
    dateOfBirth = null;
    profession = null;
    notifyListeners();
  }
}
