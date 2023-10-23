import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        ChangeNotifierProvider<MunroNotifier>(
          create: (_) => MunroNotifier(),
        ),
      ],
      child: MaterialApp(
        theme: MyTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
