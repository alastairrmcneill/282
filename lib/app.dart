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
        Provider(
          create: (_) => NotificationsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => PostsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => ProfileRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => ReportRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => ReviewsRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => SavedListRepository(Supabase.instance.client),
        ),
        Provider(
          create: (_) => SavedListMunroRepository(Supabase.instance.client),
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
        ChangeNotifierProvider<NavigationState>(
          create: (_) => NavigationState(),
        ),
        ChangeNotifierProvider<UserLikeState>(
          create: (ctx) => UserLikeState(
            ctx.read<LikesRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (ctx) => ProfileState(
            ctx.read<ProfileRepository>(),
            ctx.read<MunroPicturesRepository>(),
            ctx.read<PostsRepository>(),
            ctx.read<UserState>(),
            ctx.read<UserLikeState>(),
            ctx.read<FollowersRepository>(),
            ctx.read<MunroCompletionsRepository>(),
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
          create: (ctx) => CreatePostState(
            ctx.read<PostsRepository>(),
            ctx.read<MunroPicturesRepository>(),
            ctx.read<UserState>(),
            ctx.read<MunroCompletionState>(),
          ),
        ),
        ChangeNotifierProvider<FeedState>(
          create: (ctx) => FeedState(
            ctx.read<PostsRepository>(),
            ctx.read<UserState>(),
            ctx.read<UserLikeState>(),
          ),
        ),
        ChangeNotifierProvider<CommentsState>(
          create: (ctx) => CommentsState(
            ctx.read<CommentsRepository>(),
            ctx.read<UserState>(),
            ctx.read<PostsRepository>(),
          ),
        ),

        ChangeNotifierProvider<NotificationsState>(
          create: (ctx) => NotificationsState(
            ctx.read<NotificationsRepository>(),
            ctx.read<UserState>(),
          ),
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

        ChangeNotifierProvider<ReviewsState>(
          create: (ctx) => ReviewsState(
            ctx.read<ReviewsRepository>(),
            ctx.read<MunroState>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<CreateReviewState>(
          create: (ctx) => CreateReviewState(
            ctx.read<ReviewsRepository>(),
            ctx.read<UserState>(),
            ctx.read<MunroState>(),
          ),
        ),
        ChangeNotifierProvider<AchievementsState>(
          create: (_) => AchievementsState(),
        ),
        ChangeNotifierProvider<WeatherState>(
          create: (_) => WeatherState(),
        ),
        ChangeNotifierProvider<SavedListState>(
          create: (ctx) => SavedListState(
            ctx.read<SavedListRepository>(),
            ctx.read<SavedListMunroRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<BulkMunroUpdateState>(
          create: (_) => BulkMunroUpdateState(),
        ),
        ChangeNotifierProvider<ReportState>(
          create: (ctx) => ReportState(
            ctx.read<ReportRepository>(),
            ctx.read<UserState>(),
          ),
        ),
        ChangeNotifierProvider<LayoutState>(
          create: (_) => LayoutState(),
        ),
        ChangeNotifierProvider<GroupFilterState>(
          create: (_) => GroupFilterState(),
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
