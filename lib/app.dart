import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/app_bootstrap.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/app_intent_coordinator.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/support/app_router.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class App extends StatelessWidget {
  final AppEnvironment environment;

  const App({
    super.key,
    required this.environment,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: environment != AppEnvironment.prod,
      theme: MyTheme.lightTheme,
      navigatorKey: navigatorKey,
      navigatorObservers: [context.read<AppRouteObserver>()],
      onGenerateRoute: AppRouter.generateRoute,
      home: AppBootstrap(
        child: AppIntentCoordinator(
          child: HardAppUpdateDialog(
            child: WhatsNewDialog(
              child: AppUpdateDialog(
                child: FeedbackSurvey(
                  child: HomeScreen(key: homeScreenKey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
