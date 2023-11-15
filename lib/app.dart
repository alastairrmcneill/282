import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/screens/auth_home_screen.dart';
import 'package:two_eight_two/features/home/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/auth_service.dart';
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
        ChangeNotifierProvider<MunroNotifier>(
          create: (_) => MunroNotifier(),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (_) => ProfileState(),
        ),
        ChangeNotifierProvider<FollowersState>(
          create: (_) => FollowersState(),
        ),
        ChangeNotifierProvider<SearchState>(
          create: (_) => SearchState(),
        ),
        ChangeNotifierProvider<PostState>(
          create: (_) => PostState(),
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
