import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firstgenapp/auth_gate.dart';
import 'package:firstgenapp/services/firebase_service.dart';
// import 'package:firstgenapp/services/inapp_purchase_service.dart'; // Commented out
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
  // await RevenueCatService().init(); // Commented out RevenueCat initialization
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
        // Provider<RevenueCatService>(create: (_) => RevenueCatService()), // Commented out RevenueCat service provider
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
        // --- START: Original RevenueCat Subscription Provider (Commented out) ---
        // ChangeNotifierProxyProvider<AuthProvider, SubscriptionProvider>(
        //   create: (context) =>
        //       SubscriptionProvider(context.read<RevenueCatService>()),
        //   update: (context, auth, subscription) {
        //     if (auth.user != null) {
        //       context.read<RevenueCatService>().login(auth.user!.uid);
        //     } else {
        //       context.read<RevenueCatService>().logout();
        //     }
        //     return subscription!;
        //   },
        // ),
        // --- END: Original RevenueCat Subscription Provider ---

        // --- START: New Firebase Subscription Provider ---
        // This provider now uses FirebaseService directly to check subscription status.
        // It's a simple ChangeNotifierProvider because it no longer needs to be updated
        // by the AuthProvider in the same way. The auth state is handled internally
        // by the FirebaseService methods it calls.
        ChangeNotifierProvider<SubscriptionProvider>(
          create: (context) =>
              SubscriptionProvider(context.read<FirebaseService>()),
        ),
        // --- END: New Firebase Subscription Provider ---
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
