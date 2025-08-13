// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';

class AuthException implements Exception {
  final String message;

  // The original error code from FirebaseAuth (e.g., 'user-not-found').
  final String? code;

  // The pending credential, used for account linking scenarios.
  final AuthCredential? credential;

  // MODIFICATION: Added email for account linking.
  final String? email;

  AuthException(this.message, {this.code, this.credential, this.email});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}
