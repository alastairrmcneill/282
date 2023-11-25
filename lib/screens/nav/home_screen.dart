// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  final int? startingIndex;
  const HomeScreen({super.key, this.startingIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  late int _currentIndex;
  final List<Widget> _screens = [
    const ExploreTab(),
    const FeedTab(),
    const RecordTab(),
    const SavedTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    _currentIndex = widget.startingIndex!;
    SettingsSerivce.loadSettings(context);
    _loadData();

    super.initState();
  }

  Future _loadData() async {
    await UserDatabase.readCurrentUser(context).whenComplete(() => setState(() => loading = false));
    MunroService.loadMunroData(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);
    ProfileState profileState = Provider.of<ProfileState>(context);
    FollowersState followersState = Provider.of<FollowersState>(context);

    return loading
        ? const SplashScreen()
        : Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              onTap: (value) {
                // Reset notifiers
                profileState.clear();
                followersState.clear();

                // Check which screen
                if (value == 1) {
                  // Navigate to feed
                  PostService.getFeed(context);
                  NotificationsService.getUserNotifications(context);
                  setState(() => _currentIndex = value);
                }
                if (value == 4 && user == null) {
                  navigationState.setNavigateToRoute = "/profile_tab";
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
                } else {
                  if (value == 4) {
                    ProfileService.loadUserFromUid(context, userId: user!.uid!);
                  }
                  setState(() => _currentIndex = value);
                }
              },
              currentIndex: _currentIndex,
              backgroundColor: Colors.white,
              unselectedItemColor: Colors.black26,
              selectedItemColor: Colors.black87,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              selectedFontSize: 13,
              unselectedFontSize: 13,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.explore_outlined),
                  activeIcon: Icon(Icons.explore),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline_rounded),
                  activeIcon: Icon(Icons.people_rounded),
                  label: 'Feed',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.navigation_outlined),
                  activeIcon: Icon(Icons.navigation_rounded),
                  label: 'Record',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border_rounded),
                  activeIcon: Icon(Icons.bookmark_rounded),
                  label: 'Saved',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
  }
}
