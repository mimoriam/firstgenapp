import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' hide Query;
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/services/continent_service.dart';
import 'package:firstgenapp/utils/authException.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  final userCollection = "users";

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

  Future<String> uploadProfileImage(String userId, File image) async {
    try {
      // final ref = _storage.ref().child('profile_images').child('$userId.jpg');
      // await ref.putFile(image);
      // return await ref.getDownloadURL();

      return "image.png";
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

    // Start with a base query that excludes the current user.
    Query<Map<String, dynamic>> query = _firestore
        .collection(userCollection)
        .where('uid', isNotEqualTo: user.uid);

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
      List<QueryDocumentSnapshot<Map<String, dynamic>>> results =
          querySnapshot.docs;

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

    final conversationId = _getConversationId(currentUser.uid, otherUser.uid);
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

    return _database
        .ref('users/${currentUser.uid}/conversations')
        .onValue
        .asyncMap((event) async {
          if (event.snapshot.value == null) {
            return [];
          }
          final conversationIdsMap = event.snapshot.value as Map;
          final conversationIds = conversationIdsMap.keys.toList();
          final conversations = <Conversation>[];
          for (var id in conversationIds) {
            final snapshot = await _database.ref('conversations/$id').get();
            if (snapshot.exists && snapshot.value != null) {
              // FIX: Use jsonEncode/Decode to safely convert the map
              final encodedData = jsonEncode(snapshot.value);
              final data = jsonDecode(encodedData) as Map<String, dynamic>;
              conversations.add(
                Conversation.fromJson(data, id.toString(), currentUser.uid),
              );
            }
          }
          // Sort conversations to show the most recent first
          conversations.sort(
            (a, b) => b.lastMessageTimestamp.compareTo(a.lastMessageTimestamp),
          );
          return conversations;
        });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  getRecentUsers() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final querySnapshot = await _firestore
          .collection(userCollection)
          .where('uid', isNotEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(6)
          .get();

      return querySnapshot.docs;
    } catch (e) {
      log('Error getting recent users: $e');
      return [];
    }
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

  String _getConversationId(String uid1, String uid2) {
    return uid1.hashCode <= uid2.hashCode ? '$uid1-$uid2' : '$uid2-$uid1';
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
}
