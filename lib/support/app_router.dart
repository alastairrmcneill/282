import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/comments/screens/screens.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/settings/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import '../screens/screens.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case HomeScreen.route:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 0),
          settings: settings,
        );
      case ExploreTab.route:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 0),
          settings: settings,
        );
      case FeedTab.route:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 1),
          settings: settings,
        );
      case SavedTab.route:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 2),
          settings: settings,
        );
      case ProfileTab.route:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 3),
          settings: settings,
        );
      case AuthHomeScreen.route:
        return MaterialPageRoute(
          builder: (_) => const AuthHomeScreen(),
          settings: settings,
        );

      case AchievementDetailScreen.route:
        final args = settings.arguments as AchievementDetailsScreenArgs;
        return MaterialPageRoute(
          builder: (_) => AchievementDetailScreen(args: args),
          settings: settings,
        );
      case AchievementListScreen.route:
        return MaterialPageRoute(
          builder: (_) => const AchievementListScreen(),
          settings: settings,
        );
      case DocumentScreen.route:
        final args = settings.arguments as DocumentScreenArgs;
        return MaterialPageRoute(
          builder: (_) => DocumentScreen(
            args: args,
          ),
          settings: settings,
        );
      case WeatherScreen.route:
        return MaterialPageRoute(
          builder: (_) => WeatherScreen(),
          settings: settings,
        );
      case LoginScreen.route:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
      case EditReviewScreen.route:
        return MaterialPageRoute(
          builder: (_) => const EditReviewScreen(),
          settings: settings,
        );
      case ReportScreen.route:
        return MaterialPageRoute(
          builder: (_) => ReportScreen(),
          settings: settings,
        );
      case MunroScreen.route:
        final args = settings.arguments as MunroScreenArgs;

        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<MunroDetailState>(
            create: (ctx) => MunroDetailState(
              ctx.read<MunroPicturesRepository>(),
              ctx.read<UserState>(),
              ctx.read<Logger>(),
            )..init(args.munro),
            child: MunroScreen(),
          ),
          settings: settings,
        );

      case PhotoGalleryRoutes.munroGallery:
        final args = settings.arguments as MunroPhotoGalleryArgs;
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<PhotoGalleryState<MunroPicture>>(
            create: (ctx) => PhotoGalleryState<MunroPicture>(
              ctx.read<UserState>(),
              ctx.read<Logger>(),
              ({required offset, required count, required excludedAuthorIds}) {
                return ctx.read<MunroPicturesRepository>().readMunroPictures(
                      munroId: args.munroId,
                      excludedAuthorIds: excludedAuthorIds,
                      offset: offset,
                      count: count,
                    );
              },
            )..loadInitital(),
            child: PhotoGalleryScreen(title: "Photos from ${args.munroName}"),
          ),
          settings: settings,
        );

      case PhotoGalleryRoutes.profileGallery:
        final args = settings.arguments as ProfilePhotoGalleryArgs;
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider<PhotoGalleryState<MunroPicture>>(
            create: (ctx) => PhotoGalleryState<MunroPicture>(
              ctx.read<UserState>(),
              ctx.read<Logger>(),
              ({required offset, required count, required excludedAuthorIds}) {
                return ctx.read<MunroPicturesRepository>().readProfilePictures(
                      profileId: args.userId,
                      excludedAuthorIds: excludedAuthorIds,
                      offset: offset,
                      count: count,
                    );
              },
            )..loadInitital(),
            child: PhotoGalleryScreen(title: "Photos from ${args.displayName}"),
          ),
          settings: settings,
        );

      case ProfileScreen.route:
        final args = settings.arguments as ProfileScreenArgs;

        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider<ProfileState>(
              create: (ctx) => ProfileState(
                ctx.read<ProfileRepository>(),
                ctx.read<MunroPicturesRepository>(),
                ctx.read<PostsRepository>(),
                ctx.read<UserState>(),
                ctx.read<UserLikeState>(),
                ctx.read<MunroCompletionsRepository>(),
                ctx.read<Logger>(),
              )..loadProfileFromUserId(userId: args.userId),
              child: ProfileScreen(
                userId: args.userId,
              ),
            );
          },
          settings: settings,
        );

      case FollowersFollowingScreen.route:
        final args = settings.arguments as FollowersFollowingScreenArgs;

        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider<FollowersListState>(
              create: (ctx) => FollowersListState(
                ctx.read<FollowersRepository>(),
                ctx.read<UserState>(),
                ctx.read<Logger>(),
              )..loadInitialFollowersAndFollowing(userId: args.userId),
              child: FollowersFollowingScreen(
                userId: args.userId,
              ),
            );
          },
          settings: settings,
        );

      case LikesScreen.route:
        final args = settings.arguments as LikesScreenArgs;

        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider(
              create: (ctx) => LikesState(
                ctx.read<LikesRepository>(),
                ctx.read<UserState>(),
                ctx.read<Logger>(),
              )..getPostLikes(postId: args.postId),
              child: LikesScreen(postId: args.postId),
            );
          },
          settings: settings,
        );

      case UserSearchScreen.route:
        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider<UserSearchState>(
              create: (ctx) => UserSearchState(
                ctx.read<UserRepository>(),
                ctx.read<UserState>(),
                ctx.read<Logger>(),
              )..clearSearch(),
              child: const UserSearchScreen(),
            );
          },
          settings: settings,
        );

      case InAppOnboardingScreen.route:
        final args = settings.arguments as InAppOnboardingScreenArgs;

        return MaterialPageRoute(
          builder: (context) {
            return ChangeNotifierProvider<InAppOnboardingState>(
              create: (ctx) => InAppOnboardingState(
                ctx.read<UserState>(),
                ctx.read<MunroCompletionState>(),
                ctx.read<BulkMunroUpdateState>(),
                ctx.read<AchievementsState>(),
                ctx.read<UserAchievementsRepository>(),
                ctx.read<MunroState>(),
                ctx.read<AppFlagsRepository>(),
                ctx.read<SettingsState>(),
                ctx.read<PushNotificationState>(),
                ctx.read<Analytics>(),
                ctx.read<Logger>(),
              ),
              child: InAppOnboardingScreen(args: args),
            );
          },
          settings: settings,
        );

      case CommentsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const CommentsScreen(),
          settings: settings,
        );
      case ReviewsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const ReviewsScreen(),
          settings: settings,
        );
      case NotificationsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      case GroupFilterScreen.route:
        return MaterialPageRoute(
          builder: (_) => const GroupFilterScreen(),
          settings: settings,
        );
      case ForgotPasswordScreen.route:
        return MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(),
          settings: settings,
        );
      case RegistrationEmailScreen.route:
        return MaterialPageRoute(
          builder: (_) => RegistrationEmailScreen(),
          settings: settings,
        );
      case RegistrationNamesScreen.route:
        final args = settings.arguments as RegistrationNamesScreenArgs;
        return MaterialPageRoute(
          builder: (_) => RegistrationNamesScreen(args: args),
          settings: settings,
        );
      case RegistrationPasswordScreen.route:
        final args = settings.arguments as RegistrationPasswordScreenArgs;
        return MaterialPageRoute(
          builder: (_) => RegistrationPasswordScreen(args: args),
          settings: settings,
        );
      case BulkMunroUpdateScreen.route:
        return MaterialPageRoute(
          builder: (_) => const BulkMunroUpdateScreen(),
          settings: settings,
        );

      case CreatePostScreen.route:
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(),
          settings: settings,
        );
      case CreateReviewsScreen.route:
        return MaterialPageRoute(
          builder: (_) => CreateReviewsScreen(),
          settings: settings,
        );
      case EditProfileScreen.route:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
          settings: settings,
        );

      case FilterScreen.route:
        return MaterialPageRoute(
          builder: (_) => const FilterScreen(),
          settings: settings,
        );
      case InAppOnboardingMunroChallenge.route:
        final args = settings.arguments as InAppOnboardingMunroChallengeArgs;
        return MaterialPageRoute(
          builder: (_) => InAppOnboardingMunroChallenge(args: args),
          settings: settings,
        );
      case InAppOnboardingWelcome.route:
        return MaterialPageRoute(
          builder: (_) => const InAppOnboardingWelcome(),
          settings: settings,
        );

      case MunroAreaScreen.route:
        final args = settings.arguments as MunroAreaScreenArgs;
        return MaterialPageRoute(
          builder: (_) => MunroAreaScreen(args: args),
          settings: settings,
        );
      case MunroSummitsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const MunroSummitsScreen(),
          settings: settings,
        );
      case MunroChallengeListScreen.route:
        return MaterialPageRoute(
          builder: (_) => const MunroChallengeListScreen(),
          settings: settings,
        );
      case CreateMunroChallengeScreen.route:
        return MaterialPageRoute(
          builder: (_) => CreateMunroChallengeScreen(),
          settings: settings,
        );
      case MunroChallengeDetailScreen.route:
        return MaterialPageRoute(
          builder: (_) => const MunroChallengeDetailScreen(),
          settings: settings,
        );

      case MunrosCompletedScreen.route:
        final args = settings.arguments as MunrosCompletedScreenArgs;
        return MaterialPageRoute(
          builder: (_) => MunrosCompletedScreen(
            munroCompletions: args.munroCompletions,
            isCurrentUser: args.isCurrentUser,
          ),
          settings: settings,
        );

      case SettingsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      case AboutScreen.route:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: settings,
        );
      case LegalScreen.route:
        return MaterialPageRoute(
          builder: (_) => const LegalScreen(),
          settings: settings,
        );
      case NotificationSettingsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const NotificationSettingsScreen(),
          settings: settings,
        );
      case PrivacySettingsScreen.route:
        return MaterialPageRoute(
          builder: (_) => PrivacySettingsScreen(),
          settings: settings,
        );
      case UnitsSettingsScreen.route:
        return MaterialPageRoute(
          builder: (_) => const UnitsSettingsScreen(),
          settings: settings,
        );
      case SplashScreen.route:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case WhatsNewScreen.route:
        return MaterialPageRoute(
          builder: (_) => const WhatsNewScreen(),
          settings: settings,
        );
      case FullScreenPhotoViewer.route:
        final args = settings.arguments as FullScreenPhotoViewerArgs;
        return MaterialPageRoute(
          builder: (_) => FullScreenPhotoViewer(args: args),
          settings: settings,
        );
      case SelectMunrosScreen.route:
        return MaterialPageRoute(
          builder: (_) => const SelectMunrosScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 0),
          settings: settings,
        );
    }
  }
}
