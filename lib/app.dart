import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
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
  final AppEnvironment environment;

  const App({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    AnalyticsService.logOpen();
    return MultiProvider(
      providers: [
        // DB layer
        Provider(
          create: (_) => MunroRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => MunroCompletionsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => UserRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => BlockedUserRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => CommentsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => FeedbackRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => FollowersRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => LikesRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => MunroPicturesRepository(Supabase.instance.client),
        ),

        StreamProvider<AppUser?>.value(
          value: AuthService.appUserStream,
          initialData: null,
        ),
        ChangeNotifierProvider<UserState>(
          create: (ctx) => UserState(
            ctx.read<UserRepository>(),
            ctx.read<BlockedUserRepository>(),
          ),
        ),
        ChangeNotifierProvider<NavigationState>(
          create: (_) => NavigationState(),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (ctx) => ProfileState(
            ctx.read<MunroPicturesRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<FollowersState>(
          create: (ctx) => FollowersState(
            ctx.read<FollowersRepository>(),
            ctx.read<UserState>(),
            ctx.read<ProfileState>(),
          ),
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
          create: (ctx) => CommentsState(
            ctx.read<CommentsRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<UserLikeState>(
          create: (ctx) => UserLikeState(
            ctx.read<LikesRepository>(),
            ctx.read<UserState>(),
            ctx.read<FeedState>(),
            ctx.read<ProfileState>(),
          ),
        ),
        ChangeNotifierProvider<NotificationsState>(
          create: (_) => NotificationsState(),
        ),
        ChangeNotifierProvider<SettingsState>(
          create: (_) => SettingsState(),
        ),
        ChangeNotifierProvider<FlavorState>(
          create: (_) => FlavorState(environment),
        ),
        ChangeNotifierProvider<LikesState>(
          create: (ctx) => LikesState(
            ctx.read<LikesRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<MunroDetailState>(
          create: (ctx) => MunroDetailState(
            ctx.read<MunroPicturesRepository>(),
            ctx.read<UserState>(),
          ),
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
        ChangeNotifierProvider<MunroCompletionState>(
          create: (ctx) => MunroCompletionState(
            ctx.read<MunroCompletionsRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProxyProvider<MunroCompletionState, MunroState>(
          create: (ctx) => MunroState(ctx.read<MunroRepository>()),
          update: (ctx, completions, munroState) {
            munroState ??= MunroState(ctx.read<MunroRepository>());
            munroState.syncCompletedIds(completions.completedMunroIds);
            return munroState;
          },
        ),
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
