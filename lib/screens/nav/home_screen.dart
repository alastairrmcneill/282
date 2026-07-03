// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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
    const GroupFilterTab(),
    const SavedTab(),
    const ProfileTab(),
  ];

  void switchTab(int index) => setState(() => _currentIndex = index);

  @override
  void initState() {
    _currentIndex = widget.startingIndex!;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final layoutState = context.read<LayoutState>();

      _loadData();
      final renderBox = _bottomNavigationKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() {
          layoutState.setBottomNavBarHeight = renderBox.size.height;
        });
      }
    });
  }

  Future _loadData() async {
    final achievementsState = context.read<AchievementsState>();
    final currentUserFollowerState = context.read<CurrentUserFollowerState>();
    final globalCompletionState = context.read<GlobalCompletionState>();

    await achievementsState.getUserAchievements();
    await currentUserFollowerState.loadInitial();
    await globalCompletionState.fetchGlobalCompletionCount();
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () async {
                      await context.read<AuthState>().signOut().then((_) {
                        context.read<MunroCompletionState>().reset();
                      });
                    },
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
        return GroupFilterTab.route;
      case 3:
        return SavedTab.route;
      case 4:
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
          final userId = context.read<AuthRepository>().currentUserId;

          if (value != 0) {
            if (userId == null) {
              Navigator.of(context).pushNamed(AuthHomeScreen.route);
              return;
            }
          }

          if (value == 0) {
            context.read<GlobalCompletionState>().fetchGlobalCompletionCount();
          }

          if (value == 1) {
            final feedState = context.read<FeedState>();
            final notificationsState = context.read<NotificationsState>();
            feedState.getGlobalFeed();
            feedState.getFriendsFeed();
            notificationsState.getUserNotifications();
          }

          if (value == 3) {
            context.read<SavedListState>().readUserSavedLists();
          }

          if (value == 0) {
            final munroState = context.read<MunroState>();
            munroState.setSelectedMunroId = null;
          }

          setState(() => _currentIndex = value);

          if (userId != null) {
            final thisYearMunroChallenge = context.read<AchievementsState>().achievements.where((achievement) =>
                achievement.type == AchievementTypes.annualGoal &&
                achievement.criteriaValue == DateTime.now().year.toString());

            if (thisYearMunroChallenge.isEmpty) return;

            final achievement = thisYearMunroChallenge.first;
            if (achievement.annualTarget == null || achievement.annualTarget == 0) {
              final appFlags = context.read<AppFlagsRepository>();
              final key = '${achievement.userId}-${achievement.achievementId}';
              if (!appFlags.hasShownAnnualChallengeDialog(key)) {
                context.read<OverlayIntentState>().enqueue(AnnualMunroChallengeDialogIntent(achievement: achievement));
              }
            }
          }
        },
        currentIndex: _currentIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        selectedFontSize: 13,
        unselectedFontSize: 13,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.mapTrifold),
            activeIcon: Icon(PhosphorIconsFill.mapTrifold),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.newspaper),
            activeIcon: Icon(PhosphorIconsFill.newspaper),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.usersThree),
            activeIcon: Icon(PhosphorIconsFill.usersThree),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.bookmarkSimple),
            activeIcon: Icon(PhosphorIconsFill.bookmarkSimple),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(PhosphorIconsRegular.user),
            activeIcon: Icon(PhosphorIconsFill.user),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
