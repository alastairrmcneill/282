import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/screens/auth_home_screen.dart';
import 'package:two_eight_two/features/home/explore/screens/screens.dart';
import 'package:two_eight_two/features/home/feed/screens/screens.dart';
import 'package:two_eight_two/features/home/profile/screens/profile_tab.dart';
import 'package:two_eight_two/features/home/record/screens/screens.dart';
import 'package:two_eight_two/features/home/saved/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class HomeScreen extends StatefulWidget {
  final int? startingIndex;
  const HomeScreen({super.key, this.startingIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    _loadData();

    super.initState();
  }

  Future _loadData() async {
    await UserDatabase.readCurrentUser(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          if (value == 4 && user == null) {
            navigationState.setNavigateToRoute = "/profile_tab";
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
          } else {
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
