// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final int? startingIndex;
  const HomeScreen({super.key, this.startingIndex = 0});

  static const String route = '/home';

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey _bottomNavigationKey = GlobalKey();
  late int _currentIndex;
  final List<Widget> _screens = [
    const ExploreTab(),
    const FeedTab(),
    const SavedTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    _currentIndex = widget.startingIndex!;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LayoutState layoutState = Provider.of<LayoutState>(context, listen: false);

      _loadData();
      final RenderBox renderBox = _bottomNavigationKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        layoutState.setBottomNavBarHeight = renderBox.size.height;
      });
    });
  }

  void _showCompletedAchievements() async {
    Future.delayed(Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AchievementsCompletedScreen(),
        );
      }
    });
  }

  Future _loadData() async {
    await SettingsSerivce.loadSettings(context);
    await context.read<UserState>().readCurrentUser();

    await context.read<MunroState>().loadMunros();
    await context.read<MunroCompletionState>().loadUserMunroCompletions();
    AchievementService.getUserAchievements(context);
    context.read<UserState>().loadBlockedUsers();
    context.read<SavedListState>().readUserSavedLists();
    PushNotificationService.checkAndUpdateFCMToken(context);
  }

  @override
  Widget build(BuildContext context) {
    AchievementsState achievementsState = Provider.of<AchievementsState>(context);

    if (achievementsState.recentlyCompletedAchievements.isNotEmpty) {
      _showCompletedAchievements();
    }

    return Consumer<UserState>(
      builder: (context, userState, child) {
        switch (userState.status) {
          case UserStatus.loading:
            return const SplashScreen();
          case UserStatus.error:
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CenterText(text: userState.error.message),
                  ElevatedButton(
                    onPressed: () => AuthService.signOut(context),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            );
          default:
            return _buildScreen(context, userState);
        }
      },
    );
  }

  String get currentTabRoute {
    switch (_currentIndex) {
      case 0:
        return ExploreTab.route;
      case 1:
        return FeedTab.route;
      case 2:
        return SavedTab.route;
      case 3:
        return ProfileTab.route;
      default:
        return HomeScreen.route;
    }
  }

  Widget _buildScreen(BuildContext context, UserState userState) {
    final user = Provider.of<AppUser?>(context, listen: false);
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    FollowersState followersState = Provider.of<FollowersState>(context, listen: false);
    final munroState = context.read<MunroState>();
    final notificationsState = context.read<NotificationsState>();
    final feedState = context.read<FeedState>();

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavigationKey,
        onTap: (value) {
          // Reset notifiers
          profileState.clear();
          followersState.clear();

          // Check which screen
          if (value == 0) {
            munroState.setSelectedMunro = null;
            munroState.setSelectedMunroId = null;
            setState(() => _currentIndex = value);
          }
          if (value == 1) {
            if (user == null) {
              navigationState.setNavigateToRoute = FeedTab.route;
              Navigator.of(context).pushNamed(AuthHomeScreen.route);
            } else {
              // Navigate to feed
              feedState.getGlobalFeed();
              feedState.getFriendsFeed();
              notificationsState.getUserNotifications();
              setState(() => _currentIndex = value);
            }
          }
          if (value == 2) {
            if (user == null) {
              navigationState.setNavigateToRoute = SavedTab.route;
              Navigator.of(context).pushNamed(AuthHomeScreen.route);
            } else {
              // Navigate to saved
              context.read<SavedListState>().readUserSavedLists();
              setState(() => _currentIndex = value);
            }
          }
          if (value == 3) {
            if (user == null) {
              navigationState.setNavigateToRoute = ProfileTab.route;
              Navigator.of(context).pushNamed(AuthHomeScreen.route);
            } else {
              // Navigate to profile
              profileState.loadProfileFromUserId(userId: user.uid!);
              setState(() => _currentIndex = value);
            }
          }
        },
        currentIndex: _currentIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        selectedFontSize: 13,
        unselectedFontSize: 13,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.map),
            activeIcon: Icon(CupertinoIcons.map_fill),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.news),
            activeIcon: Icon(CupertinoIcons.news_solid),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.bookmark),
            activeIcon: Icon(CupertinoIcons.bookmark_fill),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
