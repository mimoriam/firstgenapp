import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firstgenapp/models/activity_model.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/continent_service.dart';
import 'package:firstgenapp/utils/authException.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
 
/// Like operation status
enum LikeStatus { success, limitReached, error }
 
class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  final userCollection = "users";
  final communityCollection = "communities";
  final postCollection = "posts";
  final commentCollection = "comments";
  final eventCollection = "events";
  final activityCollection = "recent_activities";

  final Map<String, Map<String, dynamic>> _userCache = {};

  // Email/Password Login
  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in login: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      log('An unexpected error occurred in login', error: e);
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  // Email/Password Registration
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      //Update the user's display name
      // The user object is available on the returned UserCredential
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signUp: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      log('An unexpected error occurred in signUp', error: e);
      throw AuthException('An unexpected error occurred. Please try again.');
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // The user canceled the sign-in flow
      if (googleUser == null) {
        throw AuthException('Google Sign-In was cancelled by the user.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Let the handler create the appropriate exception for the UI layer
      throw _handleAuthException(e);
    } catch (e) {
      log('An unexpected error occurred during Google Sign-In: $e');
      throw AuthException('An unexpected Google Sign-In error occurred.');
    }
  }

  // Links a pending credential (from Google) to an existing email/password account.
  // The UI should call this after catching the 'account-exists-with-different-credential'
  // exception and securely getting the user's password.
  Future<UserCredential> linkCredentials({
    required String email,
    required String password,
    required AuthCredential credentialToLink,
  }) async {
    try {
      // Re-authenticate the user with their original provider (email/password) to prove they own the account.
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If re-authentication is successful, link the new credential.
      return await userCredential.user!.linkWithCredential(credentialToLink);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      log('An unexpected error occurred during account linking: $e');
      throw AuthException(
        'An unexpected error occurred while linking accounts.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      log('Unexpected error during sign out: $e');
      throw AuthException('Sign out failed. Please try again.');
    }
  }

  Future<bool> checkIfEmailInUse(String email) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: "a-dummy-password-for-checking",
      );

      await _auth.currentUser?.delete();
      return false; // Email did not exist.
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // This is the primary success case for our check, meaning the email exists.
        return true;
      }
      if (e.code == 'weak-password') {
        // This is an expected failure if the email does NOT exist.
        return false;
      }
      // Handle other potential errors during the check, assuming email is not in use.
      log('FirebaseAuthException while checking email: ${e.code}');
      return false;
    } catch (e) {
      log('An unexpected error occurred while checking email: $e');
      return false;
    }
  }

  Future<void> createUserDocument(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(userCollection).doc(userId).set(data);
    } on FirebaseException catch (e) {
      log('FirebaseException in createUserDocument: ${e.code}', error: e);
      throw Exception('Failed to create user profile in the database.');
    } catch (e) {
      log('An unexpected error occurred in createUserDocument', error: e);
      throw Exception(
        'An unexpected error occurred while saving your profile.',
      );
    }
  }

  Future<void> subscribeToGeneralAnnouncements() async {
    try {
      await _fcm.subscribeToTopic('all_users');
      log('Subscribed to all_users topic');
    } catch (e) {
      log('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromGeneralAnnouncements() async {
    try {
      await _fcm.unsubscribeFromTopic('all_users');
      log('Unsubscribed from all_users topic');
    } catch (e) {
      log('Error unsubscribing from topic: $e');
    }
  }

  Future<void> saveUserToken() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection(userCollection).doc(user.uid).update({
          'fcmToken': token,
        });
      }
    } catch (e) {
      log('Error saving FCM token: $e');
    }
  }

  Future<bool> isUserProfileComplete(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      log('Error checking user profile completeness: $e');
      return false;
    }
  }

  /// START: Manual Subscription Logic
  /// This stream now returns a map containing the subscription status, plan, and end date.
  /// This provides a single source of truth for all subscription-related UI.
  Stream<Map<String, dynamic>?> getSubscriptionStatusStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(null); // No user, no subscription status.
    }
    return _firestore.collection(userCollection).doc(user.uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return {'isSubscribed': false};
      final data = snapshot.data()!;
      if (data.containsKey('subscriptionEndDate') &&
          data['subscriptionEndDate'] is Timestamp) {
        final endDate = (data['subscriptionEndDate'] as Timestamp).toDate();
        final isSubscribed = endDate.isAfter(DateTime.now());
        // Prefer the new 'subscriptionType' field but fall back to legacy 'subscriptionPlan'
        final planValue = (data['subscriptionType'] as String?) ?? (data['subscriptionPlan'] as String?);
        // Return a map with all necessary subscription details.
        return {
          'isSubscribed': isSubscribed,
          'plan': planValue,
          'endDate': endDate,
        };
      }
      return {
        'isSubscribed': false,
      }; // Default to not subscribed if fields are missing.
    });
  }

  /// Updates the user's document in Firestore to reflect a new subscription.
  /// This is a simulation of a purchase.
  Future<void> subscribeUser(String plan) async {
    final user = _auth.currentUser;
    if (user == null) return;
  
    // Normalize plan ids to support both legacy ('monthly','weekly') and new ids ('free','premium','vip')
    // 'free' will set the plan/type but remove any subscriptionEndDate (not subscribed).
    DateTime? endDate;
    String subscriptionType = 'free';
  
    if (plan == 'monthly' || plan == 'premium' || plan == 'weekly') {
      // Treat legacy monthly/weekly/premium identifiers as 'premium' tier
      subscriptionType = 'premium';
      // weekly was previously 7 days, monthly 30 days — preserve durations where possible
      if (plan == 'weekly') {
        endDate = DateTime.now().add(const Duration(days: 7));
      } else {
        endDate = DateTime.now().add(const Duration(days: 30));
      }
    } else if (plan == 'vip') {
      // VIP treated as an extended subscription (90 days)
      subscriptionType = 'vip';
      endDate = DateTime.now().add(const Duration(days: 90));
    } else if (plan == 'free') {
      // Free plan — explicitly remove any subscription end date so user is not marked subscribed.
      await _firestore.collection(userCollection).doc(user.uid).set(
        {
          'subscriptionPlan': 'free', // legacy field (kept for backward compatibility)
          'subscriptionType': 'free', // new canonical field
          'subscriptionEndDate': FieldValue.delete(),
        },
        SetOptions(merge: true),
      );
      return;
    } else {
      // Unknown plan id — do nothing
      return;
    }
  
    // Update Firestore with the selected plan/type and calculated end date.
    await _firestore.collection(userCollection).doc(user.uid).set(
      {
        // Keep legacy field for compatibility and also write the new canonical field.
        'subscriptionPlan': plan,
        'subscriptionType': subscriptionType,
        'subscriptionEndDate': Timestamp.fromDate(endDate!),
      },
      SetOptions(merge: true),
    );
  }

  /// END: Manual Subscription Logic

  Future<String> uploadProfileImage(String userId, File image) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      log('FirebaseException in uploadProfileImage: ${e.code}', error: e);
      throw Exception('Failed to upload profile image.');
    } catch (e) {
      log('An unexpected error occurred in uploadProfileImage', error: e);
      throw Exception(
        'An unexpected error occurred while uploading your image.',
      );
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(user.uid)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot;
      } else {
        log('User document does not exist for uid: ${user.uid}');
        return null;
      }
    } on FirebaseException catch (e) {
      log('FirebaseException in getUserProfile: ${e.code}', error: e);
      throw Exception('Failed to fetch user profile.');
    } catch (e) {
      log('An unexpected error occurred in getUserProfile', error: e);
      throw Exception(
        'An unexpected error occurred while fetching your profile.',
      );
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserProfileStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error('User not logged in');
    }
    return _firestore.collection(userCollection).doc(user.uid).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserDocument(
    String userId,
  ) async {
    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot;
      }
      return null;
    } catch (e) {
      log('Error getting user document for $userId: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (data.containsKey('fullName') &&
          user.displayName != data['fullName']) {
        await user.updateDisplayName(data['fullName']);
      }

      if (data.containsKey('profileImageUrl')) {
        await user.updatePhotoURL(data['profileImageUrl']);
        _userCache.remove(user.uid);
      }

      if (data.containsKey('culturalHeritage')) {
        final countryCode = data['culturalHeritage'];
        data['continent'] = ContinentService.getContinent(countryCode);
      }

      if (data.containsKey('appNotificationsEnabled')) {
        if (data['appNotificationsEnabled'] == true) {
          await subscribeToGeneralAnnouncements();
        } else {
          await unsubscribeFromGeneralAnnouncements();
        }
      }

      await _firestore.collection(userCollection).doc(user.uid).update(data);
    } on FirebaseException catch (e) {
      log('FirebaseException in updateUserProfile: ${e.code}', error: e);
      throw Exception('Failed to update user profile.');
    } catch (e) {
      log('An unexpected error occurred in updateUserProfile', error: e);
      throw Exception(
        'An unexpected error occurred while updating your profile.',
      );
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getAllUsers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: user.uid)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      log('Error getting all users: $e');
      return [];
    }
  }

  Future<List<DocumentSnapshot>> getAllMatches({
    DocumentSnapshot? startAfter,
    int limit = 12,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return [];

    Query query = _firestore
        .collection(userCollection)
        .where('matches.${currentUser.uid}', isEqualTo: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Stream<List<DocumentSnapshot>> getAllMatchesStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection(userCollection)
        .where('matches.${currentUser.uid}', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Stream<int> getMatchesCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection(userCollection)
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return 0;
          final data = snapshot.data()!;
          if (data['matches'] is Map) {
            return (data['matches'] as Map).length;
          }
          return 0;
        });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchUsers({
    required String country,
    required List<String> languages,
    String? generation,
    String? gender,
    required int minAge,
    required int maxAge,
    required List<String> professions,
    required List<String> interests,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      Query<Map<String, dynamic>> query = _firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: user.uid);

      query = query.where('culturalHeritage', isEqualTo: country);

      if (generation != null) {
        query = query.where('generation', isEqualTo: generation);
      }
      if (gender != null) {
        query = query.where('gender', isEqualTo: gender);
      }
      if (languages.isNotEmpty) {
        query = query.where('languages', arrayContainsAny: languages);
      }
      if (professions.isNotEmpty) {
        query = query.where('profession', whereIn: professions);
      }
      if (interests.isNotEmpty) {
        query = query.where('hobbies', whereIn: interests);
      }

      final querySnapshot = await query.get();

      final now = DateTime.now();
      final minDob = DateTime(now.year - maxAge, now.month, now.day);
      final maxDob = DateTime(now.year - minAge, now.month, now.day);

      final filteredDocs = querySnapshot.docs.where((doc) {
        final dobTimestamp = doc.data()['dateOfBirth'] as Timestamp?;
        if (dobTimestamp == null) return false;
        final dob = dobTimestamp.toDate();
        return dob.isAfter(minDob) && dob.isBefore(maxDob);
      }).toList();

      return filteredDocs;
    } catch (e) {
      log('Error searching users: $e');
      return [];
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in password reset: ${e.code}', error: e);
      throw _handleAuthException(e);
    } catch (e) {
      log('An unexpected error occurred in password reset', error: e);
      throw AuthException(
        'An unexpected error occurred. Please try again later.',
      );
    }
  }

  // lib/services/firebase_service.dart

  // lib/services/firebase_service.dart

  /// Helper function to get subscription priority for sorting
  int _getSubscriptionPriority(QueryDocumentSnapshot<Map<String, dynamic>> userDoc) {
    final userData = userDoc.data();
    // Prefer the new canonical 'subscriptionType' field; fall back to legacy 'subscriptionPlan'
    final plan = (userData['subscriptionType'] as String?) ??
        (userData['subscriptionPlan'] as String?) ??
        'free';
    
    switch (plan) {
      case 'vip':
        return 0;
      case 'premium':
        return 1;
      default:
        return 2;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchUsersStrict({
    String? continent,
    List<String>? languages,
    String? generation,
    String? gender,
    int? minAge,
    int? maxAge,
    List<String>? professions,
    List<String>? interests,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final currentUserDoc = await _firestore
        .collection(userCollection)
        .doc(user.uid)
        .get();
    if (!currentUserDoc.exists) return [];

    final currentUserData = currentUserDoc.data()!;

    // Get users that the current user has already liked, matched with, or discarded to exclude them.
    final likedUserIds =
        (currentUserData['likedUsers'] as Map?)?.keys.toList() ?? [];
    final matchedUserIds =
        (currentUserData['matches'] as Map?)?.keys.toList() ?? [];
    final discardedUserIds =
        (currentUserData['discardedUsers'] as Map?)?.keys.toList() ?? [];
    final usersToExclude =
        [...likedUserIds, ...matchedUserIds, ...discardedUserIds, user.uid];

    // LOG: Exclusion and community context for debugging visibility issues
    try {
      log('searchUsersStrict INIT: user=${user.uid} '
          'likedUserIds=$likedUserIds matchedUserIds=$matchedUserIds '
          'discardedUserIds=$discardedUserIds usersToExclude=$usersToExclude');
    } catch (e) {
      log('searchUsersStrict INIT: error logging exclusion lists: $e');
    }

    // Get users who have liked the current user to prioritize them.
    final likedByUsersSnapshot = await _firestore
        .collection(userCollection)
        .where('likedUsers.${user.uid}', isEqualTo: true)
        .get();
    final likedByUserIds = likedByUsersSnapshot.docs
        .map((doc) => doc.id)
        .where((id) => !usersToExclude.contains(id))
        .toList();

    final List<String> currentUserCommunities = List<String>.from(
      currentUserData['joinedCommunities'] ?? [],
    );

    Query<Map<String, dynamic>> query = _firestore.collection(userCollection);

    if (continent != null && continent != 'Global') {
      query = query.where('continent', isEqualTo: continent);
    }
    if (generation != null) {
      query = query.where('generation', isEqualTo: generation);
    }
    if (gender != null && gender != 'Other') {
      query = query.where('gender', isEqualTo: gender);
    }

    try {
      final querySnapshot = await query.get();

      // LOG: initial candidate ids from query
      try {
        log('searchUsersStrict: initialCandidates=${querySnapshot.docs.map((d) => d.id).toList()} '
            'likedByUserIds=$likedByUserIds currentUserCommunities=$currentUserCommunities');
      } catch (e) {
        log('searchUsersStrict: error logging initial candidates: $e');
      }

      // Build results with per-candidate logging to trace why users are included/excluded.
      List<QueryDocumentSnapshot<Map<String, dynamic>>> results = [];
      for (final doc in querySnapshot.docs) {
        final docId = doc.id;
        if (usersToExclude.contains(docId)) {
          try {
            log('searchUsersStrict: excluding $docId because in usersToExclude');
          } catch (e) {
            log('searchUsersStrict: error logging exclusion for $docId: $e');
          }
          continue;
        }

        final userData = doc.data();
        final seeProfile = userData['seeProfile'] as String? ?? 'Everyone';
        final List<String> otherUserCommunities = List<String>.from(
          userData['joinedCommunities'] ?? [],
        );

        // LOG: per-user visibility and communities
        try {
          log('searchUsersStrict: candidate $docId seeProfile=$seeProfile joinedCommunities=$otherUserCommunities');
        } catch (e) {
          log('searchUsersStrict: error logging candidate $docId details: $e');
        }

        if (seeProfile == 'No Body') {
          try {
            log('searchUsersStrict: excluding $docId because seeProfile=No Body');
          } catch (e) {}
          continue;
        } else if (seeProfile == 'Only Communities I\'m In') {
          final bool hasOverlap = currentUserCommunities.any(
            (community) => otherUserCommunities.contains(community),
          );
          try {
            log('searchUsersStrict: $docId community overlap=$hasOverlap');
          } catch (e) {}
          if (!hasOverlap) {
            try {
              log('searchUsersStrict: excluding $docId due to community mismatch');
            } catch (e) {}
            continue;
          }
        }

        // Passed visibility filters
        results.add(doc);
      }

      if (minAge != null && maxAge != null) {
        final now = DateTime.now();
        final minDob = DateTime(now.year - maxAge, now.month, now.day);
        final maxDob = DateTime(now.year - minAge, now.month, now.day);

        results = results.where((doc) {
          final dobTimestamp = doc.data()['dateOfBirth'] as Timestamp?;
          if (dobTimestamp == null) return false;
          final dob = dobTimestamp.toDate();
          return dob.isAfter(minDob) && dob.isBefore(maxDob);
        }).toList();
      }

      if (languages != null && languages.isNotEmpty) {
        results = results.where((doc) {
          final userLanguages = List<String>.from(
            doc.data()['languages'] ?? [],
          );
          return languages.every((lang) => userLanguages.contains(lang));
        }).toList();
      }

      final bool hasOrFilters =
          (professions?.isNotEmpty ?? false) ||
          (interests?.isNotEmpty ?? false);

      if (hasOrFilters) {
        results = results.where((doc) {
          final data = doc.data();

          if (professions?.isNotEmpty ?? false) {
            final userProfession = data['profession'] as String?;
            if (userProfession != null &&
                professions!.contains(userProfession)) {
              return true;
            }
          }

          if (interests?.isNotEmpty ?? false) {
            final userHobbiesString = data['hobbies'] as String?;
            if (userHobbiesString != null) {
              final userInterests = userHobbiesString
                  .split(',')
                  .map((e) => e.trim())
                  .toList();
              if (interests!.any(
                (interest) => userInterests.contains(interest),
              )) {
                return true;
              }
            }
          }

          return false;
        }).toList();
      }

      // Prioritize users who have liked the current user.
      final likedByUsers = results
          .where((doc) => likedByUserIds.contains(doc.id))
          .toList();
      final otherUsers = results
          .where((doc) => !likedByUserIds.contains(doc.id))
          .toList();

      // Sort both lists by subscription priority (vip, premium, free)
      likedByUsers.sort((a, b) => _getSubscriptionPriority(a).compareTo(_getSubscriptionPriority(b)));
      otherUsers.sort((a, b) => _getSubscriptionPriority(a).compareTo(_getSubscriptionPriority(b)));

      return [...likedByUsers, ...otherUsers];
    } catch (e) {
      log('Error searching users: $e');
      return [];
    }
  }

  // CHAT FUNCTIONALITY
  Future<void> createChat(ChatUser otherUser) async {
    final currentUser = await getCurrentChatUser();
    if (currentUser == null) return;

    final conversationId = getConversationId(currentUser.uid, otherUser.uid);
    final now = DateTime.now().toUtc().toIso8601String();

    final conversationData = {
      'participants': {currentUser.uid: true, otherUser.uid: true},
      'lastMessage': '',
      'lastMessageTimestamp': now,
      'users': {
        currentUser.uid: currentUser.toJson(),
        otherUser.uid: otherUser.toJson(),
      },
      'unreadCount': {currentUser.uid: 0, otherUser.uid: 0},
      'lastMessageSenderId': '',
    };

    await _database.ref('conversations/$conversationId').set(conversationData);
    await _database
        .ref('users/${currentUser.uid}/conversations/$conversationId')
        .set(true);
    await _database
        .ref('users/${otherUser.uid}/conversations/$conversationId')
        .set(true);
  }

  Stream<List<Conversation>> getConversations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);

    final userConversationsRef = _database.ref(
      'users/${currentUser.uid}/conversations',
    );

    return userConversationsRef.onValue.switchMap((event) {
      if (event.snapshot.value == null) {
        return Stream.value([]);
      }

      final conversationIdsMap = event.snapshot.value as Map;
      final conversationIds = conversationIdsMap.keys.toList();

      if (conversationIds.isEmpty) {
        return Stream.value([]);
      }

      final conversationStreams = conversationIds.map((id) {
        return _database.ref('conversations/$id').onValue.asyncMap((
          event,
        ) async {
          if (event.snapshot.exists && event.snapshot.value != null) {
            final encodedData = jsonEncode(event.snapshot.value);
            final data = jsonDecode(encodedData) as Map<String, dynamic>;

            final participants = Map<String, dynamic>.from(
              data['participants'] as Map? ?? {},
            );
            final otherUserId = participants.keys.firstWhere(
              (key) => key != currentUser.uid,
              orElse: () => '',
            );

            if (otherUserId.isNotEmpty) {
              try {
                final userDoc = await _firestore
                    .collection(userCollection)
                    .doc(otherUserId)
                    .get();
                if (userDoc.exists) {
                  final userData = userDoc.data()!;
                  data['users'][otherUserId] = {
                    'uid': otherUserId,
                    'name': userData['fullName'] ?? 'No Name',
                    'avatarUrl':
                        userData['profileImageUrl'] ??
                        'https://picsum.photos/seed/error/200/200',
                  };
                }
              } catch (e) {
                log("Error fetching user profile for chat: $e");
              }
            }
            return Conversation.fromJson(data, id.toString(), currentUser.uid);
          }
          return null;
        });
      }).toList();

      return CombineLatestStream.list(conversationStreams).map((conversations) {
        final validConversations = conversations
            .where((c) => c != null)
            .cast<Conversation>()
            .toList();
        validConversations.sort(
          (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
        );
        return validConversations;
      });
    });
  }

  Future<void> addRecentMatch(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    await _updateRecentMatchesForUser(currentUser.uid, otherUserId);
    await _updateRecentMatchesForUser(otherUserId, currentUser.uid);
  }

  Future<void> _updateRecentMatchesForUser(
    String userId,
    String matchId,
  ) async {
    final recentMatchesRef = _database.ref('users/$userId/recent_matches');
    final snapshot = await recentMatchesRef.get();

    List<dynamic> recentMatches = [];
    if (snapshot.exists && snapshot.value is List) {
      recentMatches = List<dynamic>.from(snapshot.value as List);
    }

    recentMatches.remove(matchId);
    recentMatches.add(matchId);

    if (recentMatches.length > 6) {
      recentMatches = recentMatches.sublist(recentMatches.length - 6);
    }

    await recentMatchesRef.set(recentMatches);
  }

  Future<void> addRecentUser(String userId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }
    await addRecentMatch(userId);
  }

  Stream<List<Map<String, dynamic>>> getRecentUsers() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    final recentMatchesRef = _database.ref('users/${user.uid}/recent_matches');
    return recentMatchesRef.onValue.switchMap((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return Stream.value([]);
      }

      final recentMatchIds = List<String>.from(
        (event.snapshot.value as List).map((e) => e.toString()),
      );

      if (recentMatchIds.isEmpty) {
        return Stream.value([]);
      }

      return _firestore
          .collection(userCollection)
          .where('uid', whereIn: recentMatchIds)
          .snapshots()
          .map((snapshot) {
            final orderedDocs = <Map<String, dynamic>>[];
            for (final userId in recentMatchIds.reversed) {
              try {
                final doc = snapshot.docs.firstWhere((d) => d.id == userId);
                final data = doc.data();
                final dob = (data['dateOfBirth'] as Timestamp?)?.toDate();
                final age = dob != null
                    ? (DateTime.now().difference(dob).inDays / 365).floor()
                    : null;

                orderedDocs.add({
                  'uid': doc.id,
                  'name': data['fullName'] as String? ?? 'No Name',
                  'avatar':
                      data['profileImageUrl'] as String? ??
                      'https://picsum.photos/seed/${doc.id}/200/200',
                  'imageUrl': data['profileImageUrl'] as String?,
                  'age': age,
                  'countryCode': data['culturalHeritage'] as String?,
                  'interests':
                      (data['hobbies'] as String?)
                          ?.split(',')
                          .map((e) => e.trim())
                          .toList() ??
                      [],
                  'languages': List<String>.from(data['languages'] ?? []),
                  'about': data['bio'] as String?,
                  'profession': data['profession'] as String?,
                });
              } catch (e) {
                log("User profile not found for UID: $userId");
              }
            }
            return orderedDocs;
          });
    });
  }

  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _database
        .ref('messages/$conversationId')
        .orderByChild('timestamp')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return [];
          }
          final encodedData = jsonEncode(event.snapshot.value);
          final messagesMap = jsonDecode(encodedData) as Map<String, dynamic>;
          final messages = messagesMap.entries
              .map(
                (e) => ChatMessage.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  e.key,
                ),
              )
              .toList();
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return messages;
        });
  }

  Future<void> sendMessage(
    String conversationId, {
    String? text,
    File? image,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    if (text == null && image == null) return;

    final messageId = _database.ref().push().key;
    final now = DateTime.now().toUtc().toIso8601String();
    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadChatImage(conversationId, messageId!, image);
    }

    final message = ChatMessage(
      id: messageId!,
      text: text,
      senderId: currentUser.uid,
      timestamp: now,
      imageUrl: imageUrl,
    );

    await _database
        .ref('messages/$conversationId/$messageId')
        .set(message.toJson());

    final conversationRef = _database.ref('conversations/$conversationId');
    final snapshot = await conversationRef.get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final participants = Map<String, dynamic>.from(
        data['participants'] as Map,
      );
      final otherUserId = participants.keys.firstWhere(
        (id) => id != currentUser.uid,
      );

      final lastMessage = image != null ? 'Photo' : text!;
      conversationRef.update({
        'lastMessage': lastMessage,
        'lastMessageTimestamp': now,
        'lastMessageSenderId': currentUser.uid,
      });
      conversationRef
          .child('unreadCount/$otherUserId')
          .set(ServerValue.increment(1));

      _sendNotification(otherUserId, lastMessage);
    }
  }

  Future<String> uploadChatImage(
    String conversationId,
    String messageId,
    File image,
  ) async {
    try {
      final ref = _storage
          .ref()
          .child('chat_images')
          .child(conversationId)
          .child('$messageId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      log('FirebaseException in uploadChatImage: ${e.code}', error: e);
      throw Exception('Failed to upload chat image.');
    } catch (e) {
      log('An unexpected error occurred in uploadChatImage', error: e);
      throw Exception(
        'An unexpected error occurred while uploading your image.',
      );
    }
  }

  Future<void> _sendNotification(String recipientId, String message) async {
    final currentUser = await getCurrentChatUser();
    if (currentUser == null) return;

    try {
      final recipientDoc = await _firestore
          .collection(userCollection)
          .doc(recipientId)
          .get();
      if (recipientDoc.exists) {
        final recipientData = recipientDoc.data()!;
        final bool appNotificationsEnabled =
            recipientData['appNotificationsEnabled'] ?? true;

        if (!appNotificationsEnabled) {
          log('User $recipientId has disabled app notifications.');
          return;
        }

        final recipientToken = recipientData['fcmToken'];
        if (recipientToken != null) {
          log('--- SIMULATING NOTIFICATION ---');
          log('Recipient Token: $recipientToken');
          log('Sender: ${currentUser.name}');
          log('Message: $message');
          log('-----------------------------');
        }
      }
    } catch (e) {
      log('Error sending notification: $e');
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    await _database
        .ref('conversations/$conversationId/unreadCount/${currentUser.uid}')
        .set(0);
  }

  Future<ChatUser?> getCurrentChatUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final profile = await getUserProfile();
    if (profile == null) return null;
    return ChatUser(
      uid: user.uid,
      name: profile.data()?['fullName'] ?? 'No Name',
      avatarUrl:
          profile.data()?['profileImageUrl'] ??
          'https://picsum.photos/seed/${Random().nextInt(1000)}/200/200',
    );
  }

  String getConversationId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1-$uid2' : '$uid2-$uid1';
  }

  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final conversationId = getConversationId(currentUser.uid, otherUserId);
    final conversationRef = _database.ref('conversations/$conversationId');

    final snapshot = await conversationRef.get();
    if (!snapshot.exists) {
      final otherUserDoc = await _firestore
          .collection(userCollection)
          .doc(otherUserId)
          .get();
      if (!otherUserDoc.exists) {
        throw Exception("Other user profile not found");
      }

      final otherUserData = otherUserDoc.data()!;
      final otherUser = ChatUser(
        uid: otherUserId,
        name: otherUserData['fullName'] ?? 'No Name',
        avatarUrl:
            otherUserData['profileImageUrl'] ??
            'https://picsum.photos/seed/$otherUserId/200/200',
      );
      await createChat(otherUser);
    }

    final finalSnapshot = await conversationRef.get();
    final encodedData = jsonEncode(finalSnapshot.value);
    final data = jsonDecode(encodedData) as Map<String, dynamic>;

    return Conversation.fromJson(data, conversationId, currentUser.uid);
  }

  Future<Conversation> getOrCreateConversationWithUser(
    ChatUser otherUser,
  ) async {
    final currentUser = await getCurrentChatUser();
    if (currentUser == null) throw Exception("User not logged in");

    final conversationId = getConversationId(currentUser.uid, otherUser.uid);
    final conversationRef = _database.ref('conversations/$conversationId');

    DataSnapshot snapshot = await conversationRef.get();
    if (!snapshot.exists) {
      await createChat(otherUser);
      snapshot = await conversationRef.get();
    }

    final encodedData = jsonEncode(snapshot.value);
    final data = jsonDecode(encodedData) as Map<String, dynamic>;

    return Conversation.fromJson(data, conversationId, currentUser.uid);
  }

  Future<LikeStatus> likeUser(String likedUserId) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return LikeStatus.error;

      final currentUserRef =
          _firestore.collection(userCollection).doc(currentUser.uid);
      final likedUserRef = _firestore.collection(userCollection).doc(likedUserId);

      // 1) Retrieve User Data before transaction
      final currentUserDoc = await currentUserRef.get();
      if (!currentUserDoc.exists) {
        log('likeUser: current user document not found for uid: ${currentUser.uid}');
        return LikeStatus.error;
      }
      final Map<String, dynamic> preData = currentUserDoc.data()!;
      
      // LOG: Snapshot of current user's like/match/discard maps prior to transaction
      try {
        log('likeUser INIT: ${currentUser.uid} -> $likedUserId; '
            'likedUsers=${(preData['likedUsers'] as Map?)?.keys.toList() ?? []}, '
            'matches=${(preData['matches'] as Map?)?.keys.toList() ?? []}, '
            'discarded=${(preData['discardedUsers'] as Map?)?.keys.toList() ?? []}');
      } catch (e) {
        log('likeUser INIT: error logging preData: $e');
      }
      
      final String? subscriptionPlan = preData['subscriptionPlan'] as String?;
      final dynamic likesField = preData['dailyLikesCount'];
      int dailyLikesCount = likesField is int
          ? likesField
          : int.tryParse('${likesField ?? 0}') ?? 0;

      // Normalize lastLikeResetDate to DateTime with a safe default far in the past
      final dynamic lastLikeResetField = preData['lastLikeResetDate'];
      DateTime lastLikeResetDate;
      if (lastLikeResetField is Timestamp) {
        lastLikeResetDate = lastLikeResetField.toDate();
      } else if (lastLikeResetField is String) {
        lastLikeResetDate =
            DateTime.tryParse(lastLikeResetField) ?? DateTime(2000, 1, 1);
      } else if (lastLikeResetField is DateTime) {
        lastLikeResetDate = lastLikeResetField;
      } else {
        lastLikeResetDate = DateTime(2000, 1, 1);
      }

      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      // 2) Check Premium Status
      final bool isPremium =
          (subscriptionPlan == 'premium' || subscriptionPlan == 'vip');

      // 3) Implement Free User Limit
      if (!isPremium) {
        // If lastLikeResetDate is not today, reset count and update date
        if (!(lastLikeResetDate.year == today.year &&
            lastLikeResetDate.month == today.month &&
            lastLikeResetDate.day == today.day)) {
          dailyLikesCount = 0;
          lastLikeResetDate = today;
        }

        // Enforce limit: free users can like up to 10 times per day
        const int freeDailyLimit = 10;
        if (dailyLikesCount >= freeDailyLimit) {
          return LikeStatus.limitReached;
        }

        // Increment local counter (will be persisted inside transaction)
        dailyLikesCount += 1;
      }

      // 4) Run transaction and update user document fields inside it
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);
        DocumentSnapshot likedUserSnapshot = await transaction.get(likedUserRef);

        // LOG: Snapshot info inside transaction
        try {
          log('Transaction START for likeUser: ${currentUser.uid} -> $likedUserId');
          log('Transaction: currentUserSnapshot exists=${currentUserSnapshot.exists}');
          log('Transaction: likedUserSnapshot exists=${likedUserSnapshot.exists}');
          final Map<String, dynamic>? curSnapshotData =
              currentUserSnapshot.data() as Map<String, dynamic>?;
          final Map<String, dynamic>? likedSnapshotData =
              likedUserSnapshot.data() as Map<String, dynamic>?;
          final curLikedKeys = (curSnapshotData?['likedUsers'] as Map?)?.keys.toList() ?? [];
          final likedLikedKeys = (likedSnapshotData?['likedUsers'] as Map?)?.keys.toList() ?? [];
          log('Transaction: currentUser likedUsers keys=$curLikedKeys');
          log('Transaction: likedUser likedUsers keys=$likedLikedKeys');
          final bool isMutualCheck = (likedSnapshotData?['likedUsers'] as Map?)?.containsKey(currentUser.uid) == true;
          log('Transaction: mutual like present=${isMutualCheck}');
        } catch (e) {
          log('Transaction logging error in likeUser: $e');
        }
        
        if (!currentUserSnapshot.exists || !likedUserSnapshot.exists) {
          throw Exception("User document not found!");
        }
        
        final currentUserData =
            currentUserSnapshot.data() as Map<String, dynamic>;
        final likedUserData = likedUserSnapshot.data() as Map<String, dynamic>;

        // Add 'like' activity for the liked user
        await _addActivity(
          userId: likedUserId,
          type: ActivityType.liked,
          fromUser: currentUser,
          fromUserData: currentUserData,
        );

        // Update likedUsers map
        transaction.update(currentUserRef, {'likedUsers.$likedUserId': true});

        // If the user is not premium, also persist the updated dailyLikesCount and lastLikeResetDate
        if (!isPremium) {
          transaction.update(currentUserRef, {
            'dailyLikesCount': dailyLikesCount,
            'lastLikeResetDate': Timestamp.fromDate(lastLikeResetDate),
          });
        }

        // Handle mutual like -> match
        if (likedUserData['likedUsers'] != null &&
            likedUserData['likedUsers'][currentUser.uid] == true) {
          transaction.update(currentUserRef, {'matches.$likedUserId': true});
          transaction.update(likedUserRef, {'matches.${currentUser.uid}': true});
          await addRecentMatch(likedUserId);

          // Add 'match' activity for both users
          await _addActivity(
            userId: likedUserId,
            type: ActivityType.matched,
            fromUser: currentUser,
            fromUserData: currentUserData,
          );
          await _addActivity(
            userId: currentUser.uid,
            type: ActivityType.matched,
            fromUser: likedUserSnapshot,
            fromUserData: likedUserData,
          );
        }
      });

      // Success path - log the like operation completion
      try {
        log('likeUser SUCCESS: ${currentUser.uid} liked $likedUserId');
      } catch (e) {
        log('likeUser SUCCESS: error logging success: $e');
      }
      return LikeStatus.success;
    } catch (e, st) {
      log('Error in likeUser: $e', error: e, stackTrace: st);
      return LikeStatus.error;
    }
  }

  Future<void> superLikeUser(String likedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserRef =
        _firestore.collection(userCollection).doc(currentUser.uid);
    final likedUserRef =
        _firestore.collection(userCollection).doc(likedUserId);

    // Enforce VIP-only access and monthly limits (5 per 30 days)
    final currentUserDoc = await currentUserRef.get();
    if (!currentUserDoc.exists) return;

    final Map<String, dynamic> preData = currentUserDoc.data()!;
    final String? subscriptionPlan = preData['subscriptionPlan'] as String?;

    // Only VIP users can use Super Like
    if (subscriptionPlan != 'vip') {
      log('superLikeUser blocked: non-VIP user ${currentUser.uid}');
      return;
    }

    // Resolve counters safely
    final dynamic countField = preData['superLikeCount'];
    int superLikeCount =
        countField is int ? countField : int.tryParse('${countField ?? 0}') ?? 0;

    // Handle last reset date
    final dynamic lastResetField = preData['lastSuperLikeResetDate'];
    DateTime lastSuperLikeResetDate;
    if (lastResetField is Timestamp) {
      lastSuperLikeResetDate = lastResetField.toDate();
    } else if (lastResetField is String) {
      lastSuperLikeResetDate =
          DateTime.tryParse(lastResetField) ?? DateTime(2000, 1, 1);
    } else if (lastResetField is DateTime) {
      lastSuperLikeResetDate = lastResetField;
    } else {
      lastSuperLikeResetDate = DateTime(2000, 1, 1);
    }

    final DateTime now = DateTime.now();
    // Reset every 30 days
    if (now.difference(lastSuperLikeResetDate) >= const Duration(days: 30)) {
      superLikeCount = 0;
      lastSuperLikeResetDate = now;
    }

    const int vipMonthlyLimit = 5;
    if (superLikeCount >= vipMonthlyLimit) {
      log('superLikeUser limit reached for user ${currentUser.uid}');
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(currentUserRef);
      final likedUserSnapshot = await transaction.get(likedUserRef);

      if (!currentUserSnapshot.exists || !likedUserSnapshot.exists) {
        throw Exception("User document not found!");
      }

      final currentUserData =
          currentUserSnapshot.data() as Map<String, dynamic>;
      final likedUserData = likedUserSnapshot.data() as Map<String, dynamic>;

      // Create a match for both users
      transaction.update(currentUserRef, {'matches.$likedUserId': true});
      transaction.update(likedUserRef, {'matches.${currentUser.uid}': true});

      // Keep likedUsers consistent
      transaction.update(currentUserRef, {'likedUsers.$likedUserId': true});

      // Persist super like counters atomically
      transaction.update(currentUserRef, {
        'superLikeCount': superLikeCount + 1,
        'lastSuperLikeResetDate': Timestamp.fromDate(lastSuperLikeResetDate),
      });

      // Add 'match' activity for both users
      await _addActivity(
        userId: likedUserId,
        type: ActivityType.matched,
        fromUser: currentUser,
        fromUserData: currentUserData,
      );
      await _addActivity(
        userId: currentUser.uid,
        type: ActivityType.matched,
        fromUser: likedUserSnapshot,
        fromUserData: likedUserData,
      );
    });

    // Add to recent matches for the current user
    await addRecentUser(likedUserId);
  }

  /// Mark a user as discarded so they are excluded from future searches for the current user.
  Future<void> discardUser(String discardedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final currentUserRef =
        _firestore.collection(userCollection).doc(currentUser.uid);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(currentUserRef);
        if (!snapshot.exists) throw Exception("User document not found!");
        transaction.update(currentUserRef, {
          'discardedUsers.$discardedUserId': true,
        });
      });
    } catch (e) {
      log('Error discarding user $discardedUserId: $e');
      rethrow;
    }
  }

  Future<void> _addActivity({
    required String userId,
    required ActivityType type,
    required dynamic fromUser, // Can be User or DocumentSnapshot
    required Map<String, dynamic> fromUserData,
  }) async {
    final activityRef = _firestore.collection(activityCollection).doc();
    final activity = Activity(
      id: activityRef.id,
      userId: userId,
      type: type,
      fromUserId: fromUser is User ? fromUser.uid : fromUser.id,
      fromUserName: fromUserData['fullName'] ?? 'A user',
      fromUserAvatar: fromUserData['profileImageUrl'] ?? '',
      timestamp: Timestamp.now(),
    );
    await activityRef.set(activity.toFirestore());
  }

  Stream<List<Activity>> getRecentActivities() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(activityCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          final activities = snapshot.docs
              .map((doc) => Activity.fromFirestore(doc))
              .toList();
          final uniqueActivities = <String, Activity>{};
          for (final activity in activities) {
            // Use a combination of fromUserId and type to identify unique actions
            final uniqueKey = '${activity.fromUserId}-${activity.type}';
            if (!uniqueActivities.containsKey(uniqueKey)) {
              uniqueActivities[uniqueKey] = activity;
            }
          }
          return uniqueActivities.values.toList();
        });
  }

  Future<void> createMatch(String matchedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserRef = _firestore
        .collection(userCollection)
        .doc(currentUser.uid);
    final matchedUserRef = _firestore
        .collection(userCollection)
        .doc(matchedUserId);

    return _firestore.runTransaction((transaction) async {
      transaction.update(currentUserRef, {'matches.$matchedUserId': true});
      transaction.update(matchedUserRef, {'matches.${currentUser.uid}': true});
    });
  }

  Stream<int> get unreadMessagesCount {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    final userConversationsRef = _database.ref(
      'users/${currentUser.uid}/conversations',
    );

    return userConversationsRef.onValue.switchMap((event) {
      if (event.snapshot.value == null) {
        return Stream.value(0);
      }

      final conversationIdsMap = event.snapshot.value as Map;
      final conversationIds = conversationIdsMap.keys.toList();

      if (conversationIds.isEmpty) {
        return Stream.value(0);
      }

      final conversationStreams = conversationIds.map((id) {
        return _database
            .ref('conversations/$id/unreadCount/${currentUser.uid}')
            .onValue;
      }).toList();

      return CombineLatestStream.list(conversationStreams).map((snapshots) {
        int totalUnread = 0;
        for (var snapshot in snapshots) {
          if (snapshot.snapshot.value != null) {
            final count = snapshot.snapshot.value;
            if (count is int) {
              totalUnread += count;
            }
          }
        }
        return totalUnread;
      });
    });
  }

  Future<List<Community>> getAllCommunities({
    DocumentSnapshot? startAfter,
    String searchQuery = '',
  }) async {
    Query query = _firestore
        .collection(communityCollection)
        .orderBy('createdAt', descending: true);

    if (searchQuery.isNotEmpty) {
      query = query
          .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
          .where('name_lowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    query = query.limit(10);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList();
  }

  // Real-time stream for all communities (used by the compact "All Communities" section).
  Stream<List<Community>> getAllCommunitiesStream({String searchQuery = '', int limit = 10}) {
    Query query = _firestore.collection(communityCollection).orderBy('createdAt', descending: true);
    if (searchQuery.isNotEmpty) {
      query = query
        .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
        .where('name_lowercase', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }
    query = query.limit(limit);
    return query.snapshots().map((snap) => snap.docs.map((d) => Community.fromFirestore(d)).toList());
  }

  Future<List<Post>> getFeedForUser(
    String userId, {
    DocumentSnapshot? startAfter,
  }) async {
    final userDoc = await _firestore
        .collection(userCollection)
        .doc(userId)
        .get();
    final List<String> joinedCommunities = List<String>.from(
      userDoc.data()?['joinedCommunities'] ?? [],
    );

    Query query;
    if (joinedCommunities.isEmpty) {
      query = _firestore
          .collection(postCollection)
          .where('authorId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10);
    } else {
      query = _firestore
          .collection(postCollection)
          .where(
            Filter.or(
              Filter('authorId', isEqualTo: userId),
              Filter('communityId', whereIn: joinedCommunities),
            ),
          )
          .orderBy('timestamp', descending: true)
          .limit(10);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Stream<List<Post>> getFeedStreamForUser(String userId) {
    final userCommunitiesStream = _firestore
        .collection(userCollection)
        .doc(userId)
        .snapshots()
        .map(
          (doc) => List<String>.from(doc.data()?['joinedCommunities'] ?? []),
        );

    return userCommunitiesStream.switchMap((joinedCommunities) {
      if (joinedCommunities.isEmpty) {
        return _firestore
            .collection(postCollection)
            .where('authorId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots()
            .map(
              (snapshot) =>
                  snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
            );
      } else {
        return _firestore
            .collection(postCollection)
            .where(
              Filter.or(
                Filter('authorId', isEqualTo: userId),
                Filter('communityId', whereIn: joinedCommunities),
              ),
            )
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots()
            .map(
              (snapshot) =>
                  snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
            );
      }
    });
  }

  Future<List<Community>> getCreatedCommunities(String userId) async {
    final snapshot = await _firestore
        .collection(communityCollection)
        .where('creatorId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList();
  }

  Future<List<Community>> getJoinedCommunities(String userId) async {
    final userDoc = await _firestore
        .collection(userCollection)
        .doc(userId)
        .get();
    final List<String> joinedCommunityIds = List<String>.from(
      userDoc.data()?['joinedCommunities'] ?? [],
    );

    if (joinedCommunityIds.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection(communityCollection)
        .where(FieldPath.documentId, whereIn: joinedCommunityIds)
        .get();
    return snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList();
  }

  Future<List<Community>> getJoinedCommunitiesForUser(String userId) async {
    final userDoc = await _firestore
        .collection(userCollection)
        .doc(userId)
        .get();
    if (!userDoc.exists) {
      return [];
    }
    final List<String> joinedCommunityIds = List<String>.from(
      userDoc.data()?['joinedCommunities'] ?? [],
    );

    if (joinedCommunityIds.isEmpty) {
      return [];
    }

    final snapshot = await _firestore
        .collection(communityCollection)
        .where(FieldPath.documentId, whereIn: joinedCommunityIds)
        .get();
    return snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList();
  }

  Future<String> uploadPostImage(String postId, File image) async {
    try {
      final ref = _storage.ref().child('post_images').child('$postId.jpg');
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      log('FirebaseException in uploadPostImage: ${e.code}', error: e);
      throw Exception('Failed to upload post image.');
    } catch (e) {
      log('An unexpected error occurred in uploadPostImage', error: e);
      throw Exception(
        'An unexpected error occurred while uploading your image.',
      );
    }
  }

  Future<void> createPost({
    required String content,
    required String authorId,
    String? communityId,
    File? image,
    String? link,
    List<String>? emojis,
  }) async {
    try {
      DocumentReference postRef = _firestore.collection(postCollection).doc();
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadPostImage(postRef.id, image);
      }

      final postDoc = await postRef.get();

      Post newPost = Post(
        id: postRef.id,
        authorId: authorId,
        communityId: communityId,
        content: content,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        likes: {},
        commentCount: 0,
        originalDoc: postDoc,
        link: link,
        emojis: emojis,
      );

      await postRef.set(newPost.toFirestore());
    } catch (e) {
      log('Error creating post: $e');
      throw Exception('Failed to create post.');
    }
  }

  Future<void> updatePost(String postId, String newContent) async {
    try {
      await _firestore.collection(postCollection).doc(postId).update({
        'content': newContent,
      });
    } catch (e) {
      log('Error updating post: $e');
      throw Exception('Failed to update post.');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection(postCollection).doc(postId).delete();
    } catch (e) {
      log('Error deleting post: $e');
      throw Exception('Failed to delete post.');
    }
  }

  Future<bool> checkIfCommunityNameExists(String name) async {
    final querySnapshot = await _firestore
        .collection(communityCollection)
        .where('name_lowercase', isEqualTo: name.toLowerCase())
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> createCommunity({
    required String name,
    required String description,
    required String creatorId,
    required File image,
    required bool isInviteOnly,
    required String whoFor,
    required String whatToGain,
    required String rules,
  }) async {
    try {
      DocumentReference communityRef = _firestore
          .collection(communityCollection)
          .doc();
      DocumentReference userRef = _firestore
          .collection(userCollection)
          .doc(creatorId);

      final imageUrl = await _storage
          .ref()
          .child('community_images')
          .child(
            '${communityRef.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
          )
          .putFile(image)
          .then((task) => task.ref.getDownloadURL());

      final communityData = {
        'name': name,
        'description': description,
        'imageUrl': imageUrl,
        'creatorId': creatorId,
        'members': [creatorId],
        'isInviteOnly': isInviteOnly,
        'createdAt': Timestamp.now(),
        'whoFor': whoFor,
        'whatToGain': whatToGain,
        'rules': rules,
        'name_lowercase': name.toLowerCase(),
      };

      await _firestore.runTransaction((transaction) async {
        transaction.set(communityRef, communityData);
        transaction.update(userRef, {
          'joinedCommunities': FieldValue.arrayUnion([communityRef.id]),
        });
      });
    } catch (e) {
      log('Error creating community: $e');
      throw Exception('Failed to create community.');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        _userCache[userId] = docSnapshot.data()!;
        return docSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String userId) {
    return _firestore.collection(userCollection).doc(userId).snapshots();
  }

  Future<void> joinCommunity(String communityId, String userId) async {
    final communityRef = _firestore
        .collection(communityCollection)
        .doc(communityId);
    final userRef = _firestore.collection(userCollection).doc(userId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(communityRef, {
        'members': FieldValue.arrayUnion([userId]),
      });
      transaction.update(userRef, {
        'joinedCommunities': FieldValue.arrayUnion([communityId]),
      });
    });
  }

  Future<Community?> getCommunityById(String communityId) async {
    try {
      final docSnapshot = await _firestore
          .collection(communityCollection)
          .doc(communityId)
          .get();
      if (docSnapshot.exists) {
        return Community.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      log('Error getting community name: $e');
      return null;
    }
  }

  Stream<List<Post>> getPostsForCommunityStream(String communityId) {
    return _firestore
        .collection(postCollection)
        .where('communityId', isEqualTo: communityId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
  }

  Future<void> togglePostLike(String postId, String userId) async {
    final postRef = _firestore.collection(postCollection).doc(postId);

    return _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (postDoc.exists) {
        final post = Post.fromFirestore(postDoc);
        final isLiked = post.likes[userId] == true;
        if (isLiked) {
          transaction.update(postRef, {'likes.$userId': FieldValue.delete()});
        } else {
          transaction.update(postRef, {'likes.$userId': true});
        }
      }
    });
  }

  Stream<List<Comment>> getCommentsForPost(String postId) {
    return _firestore
        .collection('comments')
        .where('postId', isEqualTo: postId)
        .where('parentId', isNull: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

  // Get replies for a comment
  Stream<List<Comment>> getRepliesForComment(String commentId) {
    return _firestore
        .collection('comments')
        .where('parentId', isEqualTo: commentId)
        .orderBy('timestamp', descending: false) // Show oldest replies first
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList(),
        );
  }

  // Add a comment or a reply
  Future<void> addCommentOrReply({
    required String postId,
    String? parentId,
    required String authorId,
    required String text,
  }) async {
    final commentRef = _firestore.collection('comments').doc();
    final postRef = _firestore.collection(postCollection).doc(postId);

    final commentDoc = await commentRef.get();

    final comment = Comment(
      id: commentRef.id,
      postId: postId,
      parentId: parentId,
      authorId: authorId,
      text: text,
      timestamp: Timestamp.now(),
      likes: {},
      originalDoc: commentDoc,
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, comment.toFirestore());
      transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
      if (parentId != null) {
        final parentCommentRef = _firestore
            .collection('comments')
            .doc(parentId);
        transaction.update(parentCommentRef, {
          'replyCount': FieldValue.increment(1),
        });
      }
    });
  }

  // Toggle like on a comment or reply
  Future<void> toggleCommentLike(String commentId, String userId) async {
    final commentRef = _firestore.collection('comments').doc(commentId);
    final commentDoc = await commentRef.get();
    if (commentDoc.exists) {
      final isLiked = (commentDoc.data()?['likes'] as Map?)?[userId] == true;
      if (isLiked) {
        await commentRef.update({'likes.$userId': FieldValue.delete()});
      } else {
        await commentRef.update({'likes.$userId': true});
      }
    }
  }

  Future<void> createEvent({
    required String communityId,
    required String creatorId,
    required String title,
    required String description,
    required File image,
    required DateTime eventDate,
    required String location,
  }) async {
    final eventRef = _firestore.collection(eventCollection).doc();
    final imageUrl = await _storage
        .ref()
        .child('event_images')
        .child('${eventRef.id}.jpg')
        .putFile(image)
        .then((task) => task.ref.getDownloadURL());

    final eventData = {
      'communityId': communityId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'interestedUserIds': [creatorId], // Creator is automatically interested
    };

    await _firestore.runTransaction((transaction) async {
      final userRef = _firestore.collection(userCollection).doc(creatorId);
      transaction.set(eventRef, eventData);
      transaction.update(userRef, {'eventCount': FieldValue.increment(1)});
    });
  }

  Future<void> toggleEventInterest(String eventId, String userId) async {
    final eventRef = _firestore.collection(eventCollection).doc(eventId);
    final userRef = _firestore.collection(userCollection).doc(userId);

    await _firestore.runTransaction((transaction) async {
      final eventDoc = await transaction.get(eventRef);
      if (!eventDoc.exists) {
        throw Exception("Event not found!");
      }

      final interestedUserIds = List<String>.from(
        eventDoc.data()!['interestedUserIds'] ?? [],
      );
      if (interestedUserIds.contains(userId)) {
        transaction.update(eventRef, {
          'interestedUserIds': FieldValue.arrayRemove([userId]),
        });
        transaction.update(userRef, {'eventCount': FieldValue.increment(-1)});
      } else {
        transaction.update(eventRef, {
          'interestedUserIds': FieldValue.arrayUnion([userId]),
        });
        transaction.update(userRef, {'eventCount': FieldValue.increment(1)});
      }
    });
  }

  Stream<List<Event>> getEventsForCommunity(String communityId) {
    return _firestore
        .collection(eventCollection)
        .where('communityId', isEqualTo: communityId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<Event>> getInterestedEventsForUser(String userId) {
    return _firestore
        .collection(eventCollection)
        .where('interestedUserIds', arrayContains: userId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList(),
        );
  }

  Stream<int> getEventCount() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection(userCollection)
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return 0;
          return snapshot.data()!['eventCount'] ?? 0;
        });
  }
}

AuthException _handleAuthException(FirebaseAuthException e) {
  log('FirebaseAuthException: code=${e.code}, message=${e.message}');
  String message;
  switch (e.code) {
    case 'user-not-found':
      message = 'No user found for that email.';
      break;
    case 'wrong-password':
      message = 'Incorrect password. Please try again.';
      break;
    case 'email-already-in-use':
      message = 'An account already exists for that email.';
      break;
    case 'weak-password':
      message = 'The password provided is too weak.';
      break;
    case 'invalid-email':
      message = 'The email address is not valid.';
      break;
    case 'invalid-credential':
      message = "Wrong email/password combination.";
      break;
    case 'user-disabled':
      message = 'This user account has been disabled.';
      break;
    case 'too-many-requests':
      message =
          'Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.';
      break;
    case 'network-request-failed':
      message = 'Network error. Please check your connection and try again.';
      break;
    case 'account-exists-with-different-credential':
      message = 'An account already exists with this email address.';
      break;
    default:
      message = 'An unknown authentication error occurred.';
  }
  return AuthException(message, code: e.code);
}
