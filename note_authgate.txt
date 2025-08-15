import 'package:firebase_auth/firebase_auth.dart';
import 'package:firstgenapp/screens/auth/signin/signin_screen.dart';
import 'package:firstgenapp/screens/auth/signup/signup2_screen.dart';
import 'package:firstgenapp/screens/dashboard/dashboard_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'common/error_indicator.dart';
import 'common/loading_indicator.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // If the app opens directly to the AuthGate, remove the splash screen.
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    return StreamBuilder<User?>(
      stream: firebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        final user = snapshot.data;

        if (user != null) {
          // User is signed in
          // Use profile check gate to check if user has completed sign up flow
          // or literally any other condition which the user has left unattended
          return _ProfileCheckGate(user: user);
        } else {
          return const SigninScreen();
          // return OnboardingScreen();
        }
      },
    );
  }
}

// MODIFICATION: This gate now checks if a user's profile is complete in Firestore.
class _ProfileCheckGate extends StatelessWidget {
  final User user;
  const _ProfileCheckGate({required this.user});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);

    return FutureBuilder<bool>(
      future: firebaseService.isUserProfileComplete(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }

        final isProfileComplete = snapshot.data ?? false;

        if (isProfileComplete) {
          // Profile exists, go to dashboard
          return const DashboardScreen();
        } else {
          // Profile does not exist, it's a new user (or new Google Sign-In)
          // Pre-populate view model and start the rest of the signup flow
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              viewModel.populateFromUser(user);
            }
          });
          // Start from the second step of the signup process
          return const Signup2Screen();
        }
      },
    );
  }
}
