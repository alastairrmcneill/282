import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'analytics/analytics.dart';
import 'repos/repos.dart';
import 'config/app_config.dart';
import 'screens/nav/state/startup_overlay_policies.dart';
import 'screens/notifiers.dart';

List<SingleChildWidget> buildRepositories(
  SupabaseClient client,
  FirebaseAuth firebaseAuth,
  GoogleSignIn googleSignIn,
  SharedPreferences sharedPreferences,
  Mixpanel mixpanel,
  FirebaseStorage firebaseStorage,
  FirebaseRemoteConfig remoteConfig,
  PackageInfo packageInfo,
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
      Provider(create: (_) => GlobalCompletionCountRepository(client)),
      Provider(create: (_) => SettingsRepository(sharedPreferences)),
      Provider(create: (_) => AppFlagsRepository(sharedPreferences)),
      Provider(create: (_) => LocalStorageRepository(sharedPreferences)),
      Provider(create: (_) => WeartherRepository()),
      Provider(create: (_) => ShareLinkRepository()),
      Provider<Analytics>(
        create: (ctx) => MixpanelAnalytics(
          mixpanel,
          ctx.read<Logger>(),
        ),
      ),
      Provider<AppRouteObserver>(
        create: (ctx) => AppRouteObserver(ctx.read<Analytics>()),
      ),
      Provider(create: (_) => StorageRepository(firebaseStorage)),
      Provider(create: (_) => RemoteConfigRespository(remoteConfig)),
      Provider(create: (_) => DeepLinkRepository()),
      Provider<PushNotificationRepository>(
        create: (_) => PushNotificationRepository(FirebaseMessaging.instance),
      ),
      Provider<FcmTokenRepository>(
        create: (_) => FcmTokenRepository(Supabase.instance.client),
      ),
      Provider<AppInfoRepository>(create: (_) => AppInfoRepository(packageInfo)),
    ];

List<SingleChildWidget> buildGlobalStates(AppEnvironment environment) => [
      ChangeNotifierProvider<NavigationIntentState>(
        create: (ctx) => NavigationIntentState(
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<OverlayIntentState>(
        create: (ctx) => OverlayIntentState(
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<RemoteConfigState>(
        create: (ctx) => RemoteConfigState(
          ctx.read<RemoteConfigRespository>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<UserState>(
        create: (ctx) => UserState(
          ctx.read<UserRepository>(),
          ctx.read<BlockedUserRepository>(),
          ctx.read<StorageRepository>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<AuthState>(
        create: (ctx) => AuthState(
          ctx.read<AuthRepository>(),
          ctx.read<UserState>(),
          ctx.read<AppFlagsRepository>(),
          ctx.read<FcmTokenRepository>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<MunroCompletionState>(
        create: (ctx) => MunroCompletionState(
          ctx.read<MunroCompletionsRepository>(),
          ctx.read<UserState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProxyProvider<MunroCompletionState, MunroState>(
        create: (ctx) => MunroState(
          ctx.read<MunroRepository>(),
          ctx.read<Logger>(),
        ),
        update: (ctx, completions, munroState) {
          munroState ??= MunroState(
            ctx.read<MunroRepository>(),
            ctx.read<Logger>(),
          );
          munroState.syncCompletedIds(completions.completedMunroIds);
          return munroState;
        },
      ),
      ChangeNotifierProvider<GlobalCompletionState>(
        create: (ctx) => GlobalCompletionState(
          ctx.read<GlobalCompletionCountRepository>(),
          ctx.read<LocalStorageRepository>(),
          ctx.read<Logger>(),
        )..loadFromLocalStorage(),
      ),
      ChangeNotifierProvider<UserLikeState>(
        create: (ctx) => UserLikeState(
          ctx.read<LikesRepository>(),
          ctx.read<UserState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<CurrentUserFollowerState>(
        create: (ctx) => CurrentUserFollowerState(
          ctx.read<FollowersRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<CreatePostState>(
        create: (ctx) => CreatePostState(
          ctx.read<PostsRepository>(),
          ctx.read<MunroPicturesRepository>(),
          ctx.read<StorageRepository>(),
          ctx.read<UserState>(),
          ctx.read<MunroCompletionState>(),
          ctx.read<RemoteConfigState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<FeedState>(
        create: (ctx) => FeedState(
          ctx.read<PostsRepository>(),
          ctx.read<UserState>(),
          ctx.read<UserLikeState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<CommentsState>(
        create: (ctx) => CommentsState(
          ctx.read<CommentsRepository>(),
          ctx.read<UserState>(),
          ctx.read<PostsRepository>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<NotificationsState>(
        create: (ctx) => NotificationsState(
          ctx.read<NotificationsRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<SettingsState>(
        create: (ctx) => SettingsState(
          ctx.read<SettingsRepository>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<FlavorState>(
        create: (_) => FlavorState(environment),
      ),
      ChangeNotifierProvider<LikesState>(
        create: (ctx) => LikesState(
          ctx.read<LikesRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<MunroDetailState>(
        create: (ctx) => MunroDetailState(
          ctx.read<MunroPicturesRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<ReviewsState>(
        create: (ctx) => ReviewsState(
          ctx.read<ReviewsRepository>(),
          ctx.read<MunroState>(),
          ctx.read<UserState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<CreateReviewState>(
        create: (ctx) => CreateReviewState(
          ctx.read<ReviewsRepository>(),
          ctx.read<UserState>(),
          ctx.read<MunroState>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<AchievementsState>(
        create: (ctx) => AchievementsState(
          ctx.read<UserAchievementsRepository>(),
          ctx.read<UserState>(),
          ctx.read<OverlayIntentState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<WeatherState>(
        create: (ctx) => WeatherState(
          ctx.read<WeartherRepository>(),
          ctx.read<SettingsState>(),
          ctx.read<MunroState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<SavedListState>(
        create: (ctx) => SavedListState(
          ctx.read<SavedListRepository>(),
          ctx.read<SavedListMunroRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<BulkMunroUpdateState>(
        create: (_) => BulkMunroUpdateState(),
      ),
      ChangeNotifierProvider<ReportState>(
        create: (ctx) => ReportState(
          ctx.read<ReportRepository>(),
          ctx.read<UserState>(),
          ctx.read<Logger>(),
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
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<ShareMunroState>(
        create: (ctx) => ShareMunroState(
          ctx.read<ShareLinkRepository>(),
          ctx.read<Analytics>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => DeepLinkState(
          ctx.read<DeepLinkRepository>(),
          ctx.read<NavigationIntentState>(),
          ctx.read<Logger>(),
        ),
      ),
      ChangeNotifierProvider<PushNotificationState>(
        create: (ctx) => PushNotificationState(
          ctx.read<PushNotificationRepository>(),
          ctx.read<FcmTokenRepository>(),
          ctx.read<SettingsState>(),
          ctx.read<UserState>(),
          ctx.read<NavigationIntentState>(),
          ctx.read<AppInfoRepository>(),
          ctx.read<Logger>(),
        ),
      ),
      ProxyProvider4<RemoteConfigState, OverlayIntentState, AppFlagsRepository, AppInfoRepository,
          StartupOverlayPolicies>(
        update: (
          _,
          remoteConfig,
          overlays,
          flags,
          appInfo,
          __,
        ) =>
            StartupOverlayPolicies(
          remoteConfig,
          overlays,
          flags,
          appInfo,
        ),
      ),
      ChangeNotifierProvider(
        create: (ctx) => AppBootstrapState(
          ctx.read<RemoteConfigState>(),
          ctx.read<DeepLinkState>(),
          ctx.read<SettingsState>(),
          ctx.read<AuthState>(),
          ctx.read<UserState>(),
          ctx.read<MunroState>(),
          ctx.read<MunroCompletionState>(),
          ctx.read<SavedListState>(),
          ctx.read<PushNotificationState>(),
          ctx.read<StartupOverlayPolicies>(),
          ctx.read<FlavorState>(),
          ctx.read<Logger>(),
        ),
      ),
    ];
