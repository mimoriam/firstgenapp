import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/services/continent_service.dart';
import 'package:firstgenapp/utils/authException.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> searchUsersOR({
    String? country,
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

    final List<Future<QuerySnapshot<Map<String, dynamic>>>> queries = [];
    final baseQuery = _firestore
        .collection(userCollection)
        .where('uid', isNotEqualTo: user.uid);

    if (country != null) {
      queries.add(
        baseQuery.where('culturalHeritage', isEqualTo: country).get(),
      );
    }
    if (generation != null) {
      queries.add(baseQuery.where('generation', isEqualTo: generation).get());
    }
    if (gender != null) {
      queries.add(baseQuery.where('gender', isEqualTo: gender).get());
    }
    if (languages != null && languages.isNotEmpty) {
      queries.add(
        baseQuery.where('languages', arrayContainsAny: languages).get(),
      );
    }
    if (professions != null && professions.isNotEmpty) {
      queries.add(baseQuery.where('profession', whereIn: professions).get());
    }
    if (interests != null && interests.isNotEmpty) {
      queries.add(baseQuery.where('hobbies', whereIn: interests).get());
    }

    if (queries.isEmpty) {
      return getAllUsers();
    }

    final List<QuerySnapshot<Map<String, dynamic>>> snapshots =
        await Future.wait(queries);

    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>> uniqueDocs =
        {};
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        uniqueDocs[doc.id] = doc;
      }
    }

    // Perform age filtering on the client side
    if (minAge != null && maxAge != null) {
      final now = DateTime.now();
      final minDob = DateTime(now.year - maxAge, now.month, now.day);
      final maxDob = DateTime(now.year - minAge, now.month, now.day);

      uniqueDocs.removeWhere((key, doc) {
        final dobTimestamp = doc.data()['dateOfBirth'] as Timestamp?;
        if (dobTimestamp == null) return true; // Remove if no DOB
        final dob = dobTimestamp.toDate();
        return dob.isBefore(minDob) || dob.isAfter(maxDob);
      });
    }

    return uniqueDocs.values.toList();
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
