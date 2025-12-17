import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'repos/repos.dart';
import 'config/app_config.dart';
import 'screens/notifiers.dart';

List<SingleChildWidget> buildRepositories(
  SupabaseClient client,
  FirebaseAuth firebaseAuth,
  GoogleSignIn googleSignIn,
) =>
    [
      Provider(create: (_) => AuthRepository(firebaseAuth, googleSignIn)),
      Provider(create: (_) => MunroRepository(client)),
      Provider(create: (_) => MunroCompletionsRepository(client)),
      Provider(create: (_) => UserRepository(client)),
      Provider(create: (_) => BlockedUserRepository(client)),
      Provider(create: (_) => CommentsRepository(client)),
      Provider(create: (_) => FeedbackRepository(client)),
      Provider(create: (_) => FollowersRepository(client)),
      Provider(create: (_) => LikesRepository(client)),
      Provider(create: (_) => MunroPicturesRepository(client)),
      Provider(create: (_) => NotificationsRepository(client)),
      Provider(create: (_) => PostsRepository(client)),
      Provider(create: (_) => ProfileRepository(client)),
      Provider(create: (_) => ReportRepository(client)),
      Provider(create: (_) => ReviewsRepository(client)),
      Provider(create: (_) => SavedListRepository(client)),
      Provider(create: (_) => SavedListMunroRepository(client)),
      Provider(create: (_) => UserAchievementsRepository(client)),
    ];

List<SingleChildWidget> buildGlobalStates(AppEnvironment environment) => [
      ChangeNotifierProvider<UserState>(
        create: (ctx) => UserState(
          ctx.read<UserRepository>(),
          ctx.read<BlockedUserRepository>(),
        ),
      ),
      ChangeNotifierProvider<AuthState>(
        create: (ctx) => AuthState(
          ctx.read<AuthRepository>(),
          ctx.read<UserState>(),
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
      ChangeNotifierProvider<CurrentUserFollowerState>(
        create: (ctx) => CurrentUserFollowerState(
          ctx.read<FollowersRepository>(),
          ctx.read<UserState>(),
        ),
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
        create: (ctx) => AchievementsState(
          ctx.read<UserAchievementsRepository>(),
          ctx.read<UserState>(),
        ),
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
        create: (ctx) => GroupFilterState(
          ctx.read<UserState>(),
          ctx.read<FollowersRepository>(),
          ctx.read<MunroState>(),
          ctx.read<MunroCompletionsRepository>(),
        ),
      ),
    ];
