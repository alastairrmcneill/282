import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/support/app_router.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey<HomeScreenState>();

class App extends StatelessWidget {
  final String flavor;

  const App({super.key, required this.flavor});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logOpen();
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
        ChangeNotifierProvider<SavedListState>(
          create: (_) => SavedListState(),
        ),
        ChangeNotifierProvider<BulkMunroUpdateState>(
          create: (_) => BulkMunroUpdateState(),
        ),
        ChangeNotifierProvider<ReportState>(
          create: (_) => ReportState(),
        ),
        ChangeNotifierProvider<LayoutState>(
          create: (_) => LayoutState(),
        ),
        ChangeNotifierProvider<GroupFilterState>(
          create: (_) => GroupFilterState(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: flavor == "Development",
        theme: MyTheme.lightTheme,
        navigatorKey: navigatorKey,
        navigatorObservers: [appRouteObserver],
        onGenerateRoute: AppRouter.generateRoute,
        home: WhatsNewDialog(
          child: AppUpdateDialog(
            child: FeedbackSurvey(
              child: HomeScreen(key: homeScreenKey),
            ),
          ),
        ),
      ),
    );
  }
}
