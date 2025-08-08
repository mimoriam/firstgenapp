import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/chats_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/community_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/home_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/profile_screen.dart';
import 'package:firstgenapp/screens/dashboard/navbar_content/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomeScreen(),
      SearchScreen(),
      ChatsScreen(),
      CommunityScreen(),
      ProfileScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    const textStyle = TextStyle(fontWeight: FontWeight.w500, fontSize: 12);

    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home),
        inactiveIcon: const Icon(Icons.home_outlined),
        title: ("Home"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search),
        title: ("Search"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.mail),
        inactiveIcon: const Icon(Icons.mail_outline),
        title: ("Chats"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.people),
        inactiveIcon: const Icon(Icons.people_alt_outlined),
        title: ("Community"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        inactiveIcon: const Icon(Icons.person_outline),
        title: ("Me"),
        activeColorPrimary: AppColors.primaryRed,
        inactiveColorPrimary: AppColors.textSecondary,
        textStyle: textStyle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineToSafeArea: true,
      backgroundColor: AppColors.primaryBackground,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: false,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
      padding: const EdgeInsets.only(bottom: 12, top: 3),
      decoration: const NavBarDecoration(
        colorBehindNavBar: AppColors.primaryBackground,
      ),
      navBarStyle: NavBarStyle.style6,
    );
  }
}
