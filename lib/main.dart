import 'package:firebase_core/firebase_core.dart';
import 'package:firstgenapp/auth_gate.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:firstgenapp/viewmodels/auth_provider.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/screens/onboarding/onboarding_screen.dart';
import 'package:firstgenapp/utils/appTheme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  final bool onboardingDone =
      await asyncPrefs.getBool('onboardingDone') ?? false;

  runApp(MyApp(onboardingDone: onboardingDone));
}

class MyApp extends StatelessWidget {
  final bool onboardingDone;

  const MyApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseService>(create: (_) => FirebaseService()),

        ChangeNotifierProvider<SignUpViewModel>(
          create: (context) => SignUpViewModel(context.read<FirebaseService>()),
        ),

        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(context.read<FirebaseService>()),
        ),

        // This provider will create the UserProfileViewModel and manage its state
        // based on the AuthProvider's status.
        ChangeNotifierProxyProvider<AuthProvider, UserProfileViewModel>(
          create: (context) =>
              UserProfileViewModel(context.read<FirebaseService>()),
          update: (context, authProvider, userProfileViewModel) {
            // When the user is authenticated with a complete profile,
            // fetch their profile data if it's not already loaded.
            if (authProvider.status ==
                AuthStatus.authenticated_complete_profile) {
              if (userProfileViewModel?.userProfileData == null &&
                  !userProfileViewModel!.isLoading) {
                userProfileViewModel.fetchUserProfile();
              }
            }
            // When the user logs out, clear their profile data.
            else if (authProvider.status == AuthStatus.unauthenticated) {
              userProfileViewModel?.clearProfile();
            }
            return userProfileViewModel!;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // If onboarding is done, go to AuthGate. Otherwise, show OnboardingScreen.
        home: onboardingDone ? const AuthGate() : const OnboardingScreen(),
        // home: const MyHomePage(),
      ),
    );
  }
}

// class MyHomePage extends StatelessWidget {
//   const MyHomePage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const OnboardingScreen();
//   }
// }
