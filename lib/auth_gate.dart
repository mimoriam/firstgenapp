import 'package:firstgenapp/screens/auth/signin/signin_screen.dart';
import 'package:firstgenapp/screens/auth/signup/signup2_screen.dart';
import 'package:firstgenapp/screens/dashboard/dashboard_screen.dart';
import 'package:firstgenapp/viewmodels/SignupViewModel.dart';
import 'package:firstgenapp/viewmodels/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'common/loading_indicator.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final viewModel = Provider.of<SignUpViewModel>(context, listen: false);

    FlutterNativeSplash.remove();

    switch (authProvider.status) {
      case AuthStatus.uninitialized:
      // MODIFICATION: Show loading indicator for the new authenticating state.
      case AuthStatus.authenticating:
        return const LoadingIndicator();

      case AuthStatus.unauthenticated:
        return const SigninScreen();

      case AuthStatus.authenticated_incomplete_profile:
        // MODIFICATION: Wrap the view model update in `addPostFrameCallback`
        // to prevent the "setState() called during build" error.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && authProvider.user != null) {
            viewModel.populateFromUser(authProvider.user!);
          }
        });
        return const Signup2Screen();

      case AuthStatus.authenticated_complete_profile:
        return const DashboardScreen();
    }
  }
}
