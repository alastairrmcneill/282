import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/achievements/achievements_screen.dart';
import 'package:two_eight_two/screens/auth/auth_home_screen.dart';
import 'package:two_eight_two/screens/nav/home_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  final String flavor;

  const App({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<AppUser?>.value(
          value: AuthService.appUserStream,
          initialData: null,
        ),
        ChangeNotifierProvider<UserState>(
          create: (_) => UserState(),
        ),
        ChangeNotifierProvider<NavigationState>(
          create: (_) => NavigationState(),
        ),
        ChangeNotifierProvider<MunroState>(
          create: (_) => MunroState(),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (_) => ProfileState(),
        ),
        ChangeNotifierProvider<FollowersState>(
          create: (_) => FollowersState(),
        ),
        ChangeNotifierProvider<UserSearchState>(
          create: (_) => UserSearchState(),
        ),
        ChangeNotifierProvider<CreatePostState>(
          create: (_) => CreatePostState(),
        ),
        ChangeNotifierProvider<FeedState>(
          create: (_) => FeedState(),
        ),
        ChangeNotifierProvider<CommentsState>(
          create: (_) => CommentsState(),
        ),
        ChangeNotifierProvider<UserLikeState>(
          create: (_) => UserLikeState(),
        ),
        ChangeNotifierProvider<NotificationsState>(
          create: (_) => NotificationsState(),
        ),
        ChangeNotifierProvider<SettingsState>(
          create: (_) => SettingsState(),
        ),
        ChangeNotifierProvider<FlavorState>(
          create: (_) => FlavorState(flavor),
        ),
        ChangeNotifierProvider<LikesState>(
          create: (_) => LikesState(),
        ),
        ChangeNotifierProvider<MunroDetailState>(
          create: (_) => MunroDetailState(),
        ),
        ChangeNotifierProvider<CreateReviewState>(
          create: (_) => CreateReviewState(),
        ),
        ChangeNotifierProvider<ReviewsState>(
          create: (_) => ReviewsState(),
        ),
        ChangeNotifierProvider<AchievementsState>(
          create: (_) => AchievementsState(),
        ),
        ChangeNotifierProvider<WeatherState>(
          create: (_) => WeatherState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: flavor == "Development",
        theme: MyTheme.lightTheme,
        navigatorKey: navigatorKey,
        routes: {
          HomeScreen.route: (context) => const HomeScreen(startingIndex: 0),
          HomeScreen.feedTabRoute: (context) => const HomeScreen(startingIndex: 1),
          // "/record_tab": (context) => const HomeScreen(startingIndex: 2),
          HomeScreen.savedTabRoute: (context) => const HomeScreen(startingIndex: 2),
          HomeScreen.profileTabRoute: (context) => const HomeScreen(startingIndex: 3),
          AuthHomeScreen.route: (context) => const AuthHomeScreen(),
          MunroScreen.route: (context) => const MunroScreen(),
          AchievementsScreen.route: (context) => const AchievementsScreen(),
          WeatherScreen.route: (context) => const WeatherScreen(),
        },
        home: const HomeScreen(),
      ),
    );
  }
}
