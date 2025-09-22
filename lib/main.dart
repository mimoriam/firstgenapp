// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstgenapp/auth_gate.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/services/notification_service.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:firstgenapp/viewmodels/auth_provider.dart';
import 'package:firstgenapp/viewmodels/firebase_subscription_provider.dart';
import 'package:firstgenapp/viewmodels/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/screens/onboarding/onboarding_screen.dart';
import 'package:firstgenapp/utils/appTheme.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().init();

  NotificationService().setupForegroundNotificationListener();
  FirebaseMessaging.instance.onTokenRefresh
      .listen((fcmToken) {
        final firebaseService = FirebaseService();
        if (firebaseService.currentUser != null) {
          firebaseService.saveUserToken();
        }
      })
      .onError((err) {});

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
        ChangeNotifierProxyProvider<AuthProvider, UserProfileViewModel>(
          create: (context) =>
              UserProfileViewModel(context.read<FirebaseService>()),
          update: (context, authProvider, userProfileViewModel) {
            if (authProvider.status ==
                AuthStatus.authenticated_complete_profile) {
              if (userProfileViewModel?.userProfileData == null &&
                  !userProfileViewModel!.isLoading) {
                userProfileViewModel.fetchUserProfile().then((_) {
                  if (userProfileViewModel
                          .userProfileData?['eventRemindersEnabled'] ??
                      false) {
                    final firebaseService = context.read<FirebaseService>();
                    final userId = firebaseService.currentUser?.uid;
                    if (userId != null) {
                      firebaseService
                          .getInterestedEventsForUser(userId)
                          .first
                          .then((events) {
                            NotificationService().scheduleEventReminders(
                              events,
                            );
                          });
                    }
                  }
                });
                context.read<FirebaseService>().saveUserToken();
              }
            } else if (authProvider.status == AuthStatus.unauthenticated) {
              userProfileViewModel?.clearProfile();
              NotificationService().cancelAllEventReminders();
            }
            return userProfileViewModel!;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
          create: (context) =>
              SubscriptionProvider(context.read<FirebaseService>()),
          update: (context, auth, previous) {
            // When auth state changes, re-initialize the subscription provider for the new user
            if (auth.user?.uid != previous?.userId) {
              return SubscriptionProvider(context.read<FirebaseService>());
            }
            return previous!;
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        home: onboardingDone ? const AuthGate() : const OnboardingScreen(),
      ),
    );
  }
}
