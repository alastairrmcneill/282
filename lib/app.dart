import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

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
      ],
      child: MaterialApp(
        theme: MyTheme.lightTheme,
        routes: {
          "/home_screen": (context) => const HomeScreen(startingIndex: 0),
          "/feed_tab": (context) => const HomeScreen(startingIndex: 1),
          "/record_tab": (context) => const HomeScreen(startingIndex: 2),
          "/saved_tab": (context) => const HomeScreen(startingIndex: 3),
          "/profile_tab": (context) => const HomeScreen(startingIndex: 4),
          "/auth_home_screen": (context) => const AuthHomeScreen(),
        },
        home: const HomeScreen(),
      ),
    );
  }
}
