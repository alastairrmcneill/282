// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/support/app_route_observer.dart';

class ProfileTab extends StatefulWidget {
  static const String route = '/profile_tab';
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  @override
  void initState() {
    appRouteObserver.updateCurrentScreen(ProfileTab.route);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileScreen(),
    );
  }
}
