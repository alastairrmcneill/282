import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/comments/screens/screens.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/munro/screens/munro_photo_gallery_screen.dart';
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
      case MunroScreen.route:
        return MaterialPageRoute(
          builder: (_) => MunroScreen(),
          settings: settings,
        );
      case AchievementsCompletedScreen.route:
        return MaterialPageRoute(
          builder: (_) => const AchievementsCompletedScreen(),
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
          builder: (_) => const WeatherScreen(),
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
              )..loadInitialFollowersAndFollowing(userId: args.userId),
              child: FollowersFollowingScreen(
                userId: args.userId,
              ),
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
      case LikesScreen.route:
        return MaterialPageRoute(
          builder: (_) => const LikesScreen(),
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
      case InAppOnboarding.route:
        return MaterialPageRoute(
          builder: (_) => InAppOnboarding(),
          settings: settings,
        );
      case InAppOnboardingFindFriends.route:
        return MaterialPageRoute(
          builder: (_) => InAppOnboardingFindFriends(),
          settings: settings,
        );
      case InAppOnboardingMunroChallenge.route:
        final args = settings.arguments as InAppOnboardingMunroChallengeArgs;
        return MaterialPageRoute(
          builder: (_) => InAppOnboardingMunroChallenge(args: args),
          settings: settings,
        );
      case InAppOnboardingMunroUpdates.route:
        return MaterialPageRoute(
          builder: (_) => InAppOnboardingMunroUpdates(),
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
      case MunroPhotoGallery.route:
        return MaterialPageRoute(
          builder: (_) => const MunroPhotoGallery(),
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
      case ProfilePhotoGallery.route:
        return MaterialPageRoute(
          builder: (_) => const ProfilePhotoGallery(),
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
      case UserSearchScreen.route:
        return MaterialPageRoute(
          builder: (_) => const UserSearchScreen(),
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

      default:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(startingIndex: 0),
          settings: settings,
        );
    }
  }
}
