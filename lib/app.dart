import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/app_providers.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/support/app_router.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class App extends StatelessWidget {
  final AppEnvironment environment;

  const App({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logOpen();
    final authClient = FirebaseAuth.instance;
    final googleSignInClient = GoogleSignIn.instance;
    final supabaseClient = Supabase.instance.client;
    return MultiProvider(
      providers: [
        ...buildRepositories(
          supabaseClient,
          authClient,
          googleSignInClient,
        ),
        ...buildGlobalStates(environment),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: environment != AppEnvironment.prod,
        theme: MyTheme.lightTheme,
        navigatorKey: navigatorKey,
        navigatorObservers: [appRouteObserver],
        onGenerateRoute: AppRouter.generateRoute,
        home: HardAppUpdateDialog(
          child: WhatsNewDialog(
            child: AppUpdateDialog(
              child: FeedbackSurvey(
                child: HomeScreen(key: homeScreenKey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
