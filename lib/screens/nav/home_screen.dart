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
    context.read<AchievementsState>().getUserAchievements();
    context.read<UserState>().loadBlockedUsers();
    context.read<SavedListState>().readUserSavedLists();
    context.read<CurrentUserFollowerState>().loadInitial();
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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        key: _bottomNavigationKey,
        onTap: (value) {
          final user = Provider.of<AppUser?>(context, listen: false);
          final navigationState = context.read<NavigationState>();

          if (value == 1 || value == 2 || value == 3) {
            if (user == null) {
              // store desired tab route and force auth
              final route = value == 1
                  ? FeedTab.route
                  : value == 2
                      ? SavedTab.route
                      : ProfileTab.route;
              navigationState.setNavigateToRoute = route;
              Navigator.of(context).pushNamed(AuthHomeScreen.route);
              return;
            }
          }

          if (value == 1) {
            final feedState = context.read<FeedState>();
            final notificationsState = context.read<NotificationsState>();
            feedState.getGlobalFeed();
            feedState.getFriendsFeed();
            notificationsState.getUserNotifications();
          }

          if (value == 2) {
            context.read<SavedListState>().readUserSavedLists();
          }

          if (value == 0) {
            final munroState = context.read<MunroState>();
            munroState.setSelectedMunro = null;
            munroState.setSelectedMunroId = null;
          }

          setState(() => _currentIndex = value);
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
