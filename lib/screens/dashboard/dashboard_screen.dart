import 'package:firstgenapp/common/exit_dialog.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats/chats_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/communities/community_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home/home_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/profile/profile_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/search/search_screen.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/viewmodels/community_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PersistentTabController _controller;
  int _communityScreenInitialIndex = 0;
  // FIX: Add a key to force the SearchScreen to rebuild.
  Key _searchScreenKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  void _handleSwitchTab(int tabIndex, {int? communitySubTabIndex}) {
    setState(() {
      if (communitySubTabIndex != null) {
        _communityScreenInitialIndex = communitySubTabIndex;
      }
    });
    _controller.jumpToTab(tabIndex);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(onSwitchTab: _handleSwitchTab),
      // FIX: Apply the key to the SearchScreen.
      SearchScreen(key: _searchScreenKey),
      const ChatsScreen(),
      CommunityScreen(
        key: ValueKey(_communityScreenInitialIndex),
        initialIndex: _communityScreenInitialIndex,
      ),
      const ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.home),
        inactiveIcon: const Icon(IconlyLight.home),
        title: ("Home"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.search),
        inactiveIcon: const Icon(IconlyLight.search),
        title: ("Match"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const _MessageBadge(child: Icon(IconlyBold.message)),
        inactiveIcon: const _MessageBadge(child: Icon(IconlyLight.message)),
        title: ("Chats"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.user_3),
        inactiveIcon: const Icon(IconlyBold.user_3),
        title: ("Community"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(IconlyBold.profile),
        inactiveIcon: const Icon(IconlyLight.profile),
        title: ("Me"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final userId = firebaseService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text("Authentication error.")));
    }

    return ChangeNotifierProvider(
      create: (_) => CommunityViewModel(firebaseService, userId),
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }

          if (_controller.index == 0) {
            showExitConfirmationDialogForHome(context);
          }
        },
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          confineToSafeArea: true,
          backgroundColor: AppColors.primaryBackground,
          handleAndroidBackButtonPress: true,
          resizeToAvoidBottomInset: true,
          stateManagement: true,
          hideNavigationBarWhenKeyboardAppears: true,
          popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
          padding: const EdgeInsets.only(bottom: 12, top: 3),
          decoration: const NavBarDecoration(
            colorBehindNavBar: AppColors.primaryBackground,
          ),
          navBarStyle: NavBarStyle.style6,
          // FIX: Add the onItemSelected callback to update the key.
          onItemSelected: (index) {
            FocusScope.of(context).unfocus();
            // If the search tab (index 1) is selected, generate a new key.
            if (index == 1) {
              setState(() {
                _searchScreenKey = UniqueKey();
              });
            }
          },
        ),
      ),
    );
  }
}

class _MessageBadge extends StatelessWidget {
  final Widget child;

  const _MessageBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    return StreamBuilder<int>(
      stream: firebaseService.unreadMessagesCount,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: EdgeInsets.all(count > 9 ? 4 : 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBackground,
                      width: 1.5,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
