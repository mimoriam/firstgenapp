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
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/continent_service.dart';
import 'package:firstgenapp/utils/authException.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

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

  // MODIFICATION: Added a method to check if the user's profile document exists in Firestore.
  Future<bool> isUserProfileComplete(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .get();
      return docSnapshot.exists;
    } catch (e) {
      log('Error checking user profile completeness: $e');
      return false; // Assume not complete on error
    }
  }

  // MODIFICATION: Implemented the actual image upload logic.
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
      // Return a stream that emits an error if the user is not logged in.
      return Stream.error('User not logged in');
    }
    return _firestore.collection(userCollection).doc(user.uid).snapshots();
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Ensure the full name in Auth is also updated if it has changed.
      if (data.containsKey('fullName') &&
          user.displayName != data['fullName']) {
        await user.updateDisplayName(data['fullName']);
      }

      // MODIFICATION: If a new image URL is provided, update the auth user's photoURL.
      if (data.containsKey('profileImageUrl')) {
        await user.updatePhotoURL(data['profileImageUrl']);
      }

      // MODIFICATION: If the country is being updated, also update the continent.
      if (data.containsKey('culturalHeritage')) {
        final countryCode = data['culturalHeritage'];
        data['continent'] = ContinentService.getContinent(countryCode);
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
          // Optionally, you might want to exclude the current user from the list.
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

      // Start with a base query
      Query<Map<String, dynamic>> query = _firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: user.uid);

      // Apply filters. Note: Firestore has limitations on complex queries.
      // This implementation uses multiple 'where' clauses. For more complex
      // scenarios, you might need to perform some filtering on the client-side.

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

      // Client-side filtering for age, as Firestore does not support range queries on different fields.
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

  // Password Reset
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

    // Get the current user's data to know who they've already liked or matched with
    final currentUserDoc = await _firestore
        .collection(userCollection)
        .doc(user.uid)
        .get();
    if (!currentUserDoc.exists) return [];

    final currentUserData = currentUserDoc.data()!;
    final likedUserIds =
        (currentUserData['likedUsers'] as Map?)?.keys.toList() ?? [];
    final matchedUserIds =
        (currentUserData['matches'] as Map?)?.keys.toList() ?? [];
    final usersToExclude = [...likedUserIds, ...matchedUserIds, user.uid];

    // Start with a base query that excludes the current user.
    Query<Map<String, dynamic>> query = _firestore
        .collection(userCollection)
        .where('uid', isNotEqualTo: user.uid);

    // ... (the rest of the searchUsersStrict function remains the same, but it will now exclude users)

    // Apply strict AND filters for core preferences on the server-side.
    if (continent != null && continent != 'Global') {
      query = query.where('continent', isEqualTo: continent);
    }
    if (generation != null) {
      query = query.where('generation', isEqualTo: generation);
    }
    // FIX: Check for 'Other' and skip the gender filter if it's selected.
    if (gender != null && gender != 'Other') {
      query = query.where('gender', isEqualTo: gender);
    }

    try {
      final querySnapshot = await query.get();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> results = querySnapshot
          .docs
          .where((doc) => !usersToExclude.contains(doc.id))
          .toList();

      // === Start Client-Side Filtering for remaining AND conditions ===

      // 1. Filter by Age (Strict AND)
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

      // 2. Filter by Languages (Strict AND)
      if (languages != null && languages.isNotEmpty) {
        results = results.where((doc) {
          final userLanguages = List<String>.from(
            doc.data()['languages'] ?? [],
          );
          return languages.every((lang) => userLanguages.contains(lang));
        }).toList();
      }

      // === End Client-Side AND Filtering ===

      // === Start Client-Side OR Filtering for optional criteria ===

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

      return results;
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

  // OLD: Rewrote this method to fetch fresh user data from Firestore.
  // Stream<List<Conversation>> getConversations() {
  //   final currentUser = _auth.currentUser;
  //   if (currentUser == null) return Stream.value([]);
  //
  //   final userConversationsRef = _database.ref(
  //     'users/${currentUser.uid}/conversations',
  //   );
  //
  //   return userConversationsRef.onValue.switchMap((event) {
  //     if (event.snapshot.value == null) {
  //       return Stream.value([]);
  //     }
  //
  //     final conversationIdsMap = event.snapshot.value as Map;
  //     final conversationIds = conversationIdsMap.keys.toList();
  //
  //     if (conversationIds.isEmpty) {
  //       return Stream.value([]);
  //     }
  //
  //     final conversationStreams = conversationIds.map((id) {
  //       return _database.ref('conversations/$id').onValue.asyncMap((
  //         event,
  //       ) async {
  //         if (event.snapshot.exists && event.snapshot.value != null) {
  //           final encodedData = jsonEncode(event.snapshot.value);
  //           final data = jsonDecode(encodedData) as Map<String, dynamic>;
  //
  //           final participants = Map<String, dynamic>.from(
  //             data['participants'] as Map? ?? {},
  //           );
  //           final otherUserId = participants.keys.firstWhere(
  //             (key) => key != currentUser.uid,
  //             orElse: () => '',
  //           );
  //
  //           if (otherUserId.isNotEmpty) {
  //             try {
  //               final userDoc = await _firestore
  //                   .collection(userCollection)
  //                   .doc(otherUserId)
  //                   .get();
  //               if (userDoc.exists) {
  //                 final userData = userDoc.data()!;
  //                 // Replace the stale user data in the conversation with fresh data
  //                 data['users'][otherUserId] = {
  //                   'uid': otherUserId,
  //                   'name': userData['fullName'] ?? 'No Name',
  //                   'avatarUrl':
  //                       userData['profileImageUrl'] ??
  //                       'https://picsum.photos/seed/error/200/200',
  //                 };
  //               }
  //             } catch (e) {
  //               log("Error fetching user profile for chat: $e");
  //             }
  //           }
  //           return Conversation.fromJson(data, id.toString(), currentUser.uid);
  //         }
  //         return null;
  //       });
  //     }).toList();
  //
  //     return CombineLatestStream.list(conversationStreams).map((conversations) {
  //       final validConversations = conversations
  //           .where((c) => c != null)
  //           .cast<Conversation>()
  //           .toList();
  //       validConversations.sort(
  //         (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
  //       );
  //       return validConversations;
  //     });
  //   });
  // }

  //! VERY IMPORTANT
  // Stream<List<Conversation>> getConversations() {
  //   final currentUser = _auth.currentUser;
  //   if (currentUser == null) return Stream.value([]);
  //
  //   final userConversationsRef = _database.ref(
  //     'users/${currentUser.uid}/conversations',
  //   );
  //
  //   return userConversationsRef.onValue.switchMap((event) {
  //     if (event.snapshot.value == null) {
  //       return Stream.value([]);
  //     }
  //
  //     final conversationIdsMap = event.snapshot.value as Map;
  //     final conversationIds = conversationIdsMap.keys.toList();
  //
  //     if (conversationIds.isEmpty) {
  //       return Stream.value([]);
  //     }
  //
  //     final conversationStreams = conversationIds.map((id) {
  //       return _database.ref('conversations/$id').onValue.map((event) {
  //         if (event.snapshot.exists && event.snapshot.value != null) {
  //           final encodedData = jsonEncode(event.snapshot.value);
  //           final data = jsonDecode(encodedData) as Map<String, dynamic>;
  //           return Conversation.fromJson(data, id.toString(), currentUser.uid);
  //         }
  //         return null;
  //       });
  //     }).toList();
  //
  //     return CombineLatestStream.list(conversationStreams).map((conversations) {
  //       final validConversations = conversations
  //           .where((c) => c != null)
  //           .cast<Conversation>()
  //           .toList();
  //       validConversations.sort(
  //         (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
  //       );
  //       return validConversations;
  //     });
  //   });
  // }

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
                  // Replace the stale user data in the conversation with fresh data
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

    // Add other user to current user's recent matches
    await _updateRecentMatchesForUser(currentUser.uid, otherUserId);

    // Add current user to other user's recent matches
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

    // Remove if it exists to re-add it at the end (most recent)
    recentMatches.remove(matchId);
    recentMatches.add(matchId);

    // Keep only the 6 most recent matches
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

  // FIX: Modified to return user UID for chat functionality.
  // Stream<List<Map<String, dynamic>>> getRecentUsers() {
  //   final user = _auth.currentUser;
  //   if (user == null) return Stream.value([]);
  //
  //   final recentMatchesRef = _database.ref('users/${user.uid}/recent_matches');
  //   return recentMatchesRef.onValue.switchMap((event) {
  //     if (!event.snapshot.exists || event.snapshot.value == null) {
  //       return Stream.value([]);
  //     }
  //
  //     final recentMatchIds = List<String>.from(
  //       (event.snapshot.value as List).map((e) => e.toString()),
  //     );
  //
  //     if (recentMatchIds.isEmpty) {
  //       return Stream.value([]);
  //     }
  //
  //     return _firestore
  //         .collection(userCollection)
  //         .where('uid', whereIn: recentMatchIds)
  //         .snapshots()
  //         .map((snapshot) {
  //           final orderedDocs = <Map<String, dynamic>>[];
  //           for (final userId in recentMatchIds.reversed) {
  //             try {
  //               final doc = snapshot.docs.firstWhere((d) => d.id == userId);
  //               orderedDocs.add({
  //                 'uid': doc.id,
  //                 'name': doc.data()['fullName'] as String? ?? 'No Name',
  //                 'avatar':
  //                     doc.data()['profileImageUrl'] as String? ??
  //                     'https://picsum.photos/seed/${doc.data()['uid']}/200/200',
  //               });
  //             } catch (e) {
  //               // Handle case where user profile might not be found
  //               log("User profile not found for UID: $userId");
  //             }
  //           }
  //           return orderedDocs;
  //         });
  //   });
  // }

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
                  // Corrected key to 'imageUrl' and provided a fallback
                  'avatar':
                      data['profileImageUrl'] as String? ??
                      'https://picsum.photos/seed/${doc.id}/200/200',
                  'imageUrl':
                      data['profileImageUrl']
                          as String?, // Keep for home screen
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
          // FIX: Use jsonEncode/Decode here as well
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

  Future<void> sendMessage(String conversationId, String text) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageId = _database.ref().push().key;
    final now = DateTime.now().toUtc().toIso8601String();

    final message = ChatMessage(
      id: messageId!,
      text: text,
      senderId: currentUser.uid,
      timestamp: now,
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

      conversationRef.update({
        'lastMessage': text,
        'lastMessageTimestamp': now,
        'lastMessageSenderId': currentUser.uid,
      });
      conversationRef
          .child('unreadCount/$otherUserId')
          .set(ServerValue.increment(1));

      // ADD THIS: Trigger notification
      _sendNotification(otherUserId, text);
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
        final recipientToken = recipientDoc.data()?['fcmToken'];
        if (recipientToken != null) {
          // IMPORTANT: In a production app, this logic should be in a Cloud Function
          // for security reasons. Sending notifications directly from the client
          // requires exposing your server key, which is not secure.
          log('--- SIMULATING NOTIFICATION ---');
          log('Recipient Token: $recipientToken');
          log('Sender: ${currentUser.name}');
          log('Message: $message');
          log('-----------------------------');

          // Example of how you would call a Cloud Function
          // final url = Uri.parse('YOUR_CLOUD_FUNCTION_URL');
          // await http.post(
          //   url,
          //   headers: {'Content-Type': 'application/json'},
          //   body: jsonEncode({
          //     'token': recipientToken,
          //     'title': 'New message from ${currentUser.name}',
          //     'body': message,
          //     'data': {
          //       'conversationId': getConversationId(currentUser.uid, recipientId),
          //       'otherUser': jsonEncode(currentUser.toJson()),
          //     }
          //   }),
          // );
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

  // FIX: New method to get or create a conversation
  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final conversationId = getConversationId(currentUser.uid, otherUserId);
    final conversationRef = _database.ref('conversations/$conversationId');

    final snapshot = await conversationRef.get();
    if (!snapshot.exists) {
      // Conversation doesn't exist, create it.
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

    // Fetch the (now existing) conversation data
    final finalSnapshot = await conversationRef.get();
    final encodedData = jsonEncode(finalSnapshot.value);
    final data = jsonDecode(encodedData) as Map<String, dynamic>;

    return Conversation.fromJson(data, conversationId, currentUser.uid);
  }

  // OPTIMIZATION: New method to get or create a conversation using a ChatUser object.
  // This is more efficient as it uses the already-fetched user data.
  Future<Conversation> getOrCreateConversationWithUser(
    ChatUser otherUser,
  ) async {
    final currentUser = await getCurrentChatUser();
    if (currentUser == null) throw Exception("User not logged in");

    final conversationId = getConversationId(currentUser.uid, otherUser.uid);
    final conversationRef = _database.ref('conversations/$conversationId');

    DataSnapshot snapshot = await conversationRef.get(); // First read
    if (!snapshot.exists) {
      // If the conversation doesn't exist, create it.
      await createChat(otherUser);
      // Then fetch the newly created data.
      snapshot = await conversationRef.get(); // Second read ONLY if it's new
    }

    // Use the snapshot we already have instead of fetching again.
    final encodedData = jsonEncode(snapshot.value);
    final data = jsonDecode(encodedData) as Map<String, dynamic>;

    return Conversation.fromJson(data, conversationId, currentUser.uid);
  }

  // Future<void> likeUser(String likedUserId) async {
  //   final currentUser = _auth.currentUser;
  //   if (currentUser == null) return;
  //
  //   final currentUserRef = _firestore
  //       .collection(userCollection)
  //       .doc(currentUser.uid);
  //   final likedUserRef = _firestore.collection(userCollection).doc(likedUserId);
  //
  //   return _firestore.runTransaction((transaction) async {
  //     // Get the documents
  //     DocumentSnapshot currentUserSnapshot = await transaction.get(
  //       currentUserRef,
  //     );
  //     DocumentSnapshot likedUserSnapshot = await transaction.get(likedUserRef);
  //
  //     if (!currentUserSnapshot.exists || !likedUserSnapshot.exists) {
  //       throw Exception("User document not found!");
  //     }
  //
  //     // For the current user, add the liked user to their 'likedUsers' map.
  //     transaction.update(currentUserRef, {'likedUsers.$likedUserId': true});
  //
  //     // For the liked user, increment their 'likesReceivedCount'.
  //     transaction.update(likedUserRef, {
  //       'likesReceivedCount': FieldValue.increment(1),
  //     });
  //   });
  // }

  Future<void> likeUser(String likedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserRef = _firestore
        .collection(userCollection)
        .doc(currentUser.uid);
    final likedUserRef = _firestore.collection(userCollection).doc(likedUserId);

    return _firestore.runTransaction((transaction) async {
      // Get the documents
      DocumentSnapshot currentUserSnapshot = await transaction.get(
        currentUserRef,
      );
      DocumentSnapshot likedUserSnapshot = await transaction.get(likedUserRef);

      if (!currentUserSnapshot.exists || !likedUserSnapshot.exists) {
        throw Exception("User document not found!");
      }

      // Add the liked user to the current user's 'likedUsers' map.
      transaction.update(currentUserRef, {'likedUsers.$likedUserId': true});

      // Check if the liked user has already liked the current user.
      Map<String, dynamic> likedUserData =
          likedUserSnapshot.data() as Map<String, dynamic>;
      if (likedUserData['likedUsers'] != null &&
          likedUserData['likedUsers'][currentUser.uid] == true) {
        // It's a match!
        transaction.update(currentUserRef, {'matches.$likedUserId': true});
        transaction.update(likedUserRef, {'matches.${currentUser.uid}': true});

        // Add to recent matches for both users in Realtime Database
        await addRecentMatch(likedUserId);
      }
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
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: '$searchQuery\uf8ff');
    }

    query = query.limit(10);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Community.fromFirestore(doc)).toList();
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
  }) async {
    try {
      DocumentReference postRef = _firestore.collection(postCollection).doc();
      String? imageUrl;
      if (image != null) {
        imageUrl = await uploadPostImage(postRef.id, image);
      }

      Post newPost = Post(
        id: postRef.id,
        authorId: authorId,
        communityId: communityId,
        content: content,
        imageUrl: imageUrl,
        timestamp: Timestamp.now(),
        likes: {},
        commentCount: 0,
        originalDoc: (await postRef.get()),
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
    required List<File> images,
    required bool isInviteOnly,
    required String whoFor,
    required String whatToGain,
    required String rules,
  }) async {
    try {
      DocumentReference communityRef = _firestore
          .collection(communityCollection)
          .doc();

      List<String> imageUrls = [];
      for (var image in images) {
        final imageUrl = await _storage
            .ref()
            .child('community_images')
            .child(
              '${communityRef.id}/${DateTime.now().millisecondsSinceEpoch}.jpg',
            )
            .putFile(image)
            .then((task) => task.ref.getDownloadURL());
        imageUrls.add(imageUrl);
      }

      final communityData = {
        'name': name,
        'description': description,
        'imageUrls': imageUrls,
        'creatorId': creatorId,
        'members': [creatorId],
        'isInviteOnly': isInviteOnly,
        'createdAt': Timestamp.now(),
        'whoFor': whoFor,
        'whatToGain': whatToGain,
        'rules': rules,
        'name_lowercase': name.toLowerCase(),
      };

      await communityRef.set(communityData);
    } catch (e) {
      log('Error creating community: $e');
      throw Exception('Failed to create community.');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final docSnapshot = await _firestore
          .collection(userCollection)
          .doc(userId)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      log('Error getting user data: $e');
      return null;
    }
  }

  Future<String?> getCommunityNameById(String communityId) async {
    try {
      final docSnapshot = await _firestore
          .collection(communityCollection)
          .doc(communityId)
          .get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['name'];
      }
      return null;
    } catch (e) {
      log('Error getting community name: $e');
      return null;
    }
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

  Future<void> addComment(String postId, String authorId, String text) async {
    final postRef = _firestore.collection(postCollection).doc(postId);
    final commentRef = _firestore.collection(commentCollection).doc();

    final comment = Comment(
      id: commentRef.id,
      postId: postId,
      authorId: authorId,
      text: text,
      timestamp: Timestamp.now(),
      likes: {},
    );

    await _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, comment.toFirestore());
      transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
    });
  }
}

/// Maps [FirebaseAuthException] codes to user-friendly [AuthException] objects.
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
