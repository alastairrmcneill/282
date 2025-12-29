import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class DeepLinkService {
  static StreamSubscription<Map>? _branchStreamSubscription;

  static Future<void> initBranchLinks({
    required GlobalKey<NavigatorState> navigatorKey,
    required AppEnvironment flavor,
  }) async {
    await FlutterBranchSdk.init(
      enableLogging: flavor != AppEnvironment.prod,
      branchAttributionLevel: BranchAttributionLevel.FULL,
    );

    _branchStreamSubscription = FlutterBranchSdk.listSession().listen(
      (data) {
        if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
          _handleBranchLinkData(data, navigatorKey);
        }
      },
      onError: (error) {
        print('Branch deep link error: $error');
      },
    );
  }

  static void _handleBranchLinkData(Map<dynamic, dynamic> data, GlobalKey<NavigatorState> navigatorKey) async {
    final int? munroId = data['munroId'];

    // Log data
    // context.read<Analytics>().track(AnalyticsEvent.branchLinkClicked, props: {
    //   AnalyticsProp.munroId: munroId ?? 0,
    // });

    // TODO fix

    if (munroId == null || munroId == 0) return;

    final BuildContext context = navigatorKey.currentContext!;
    final munroState = context.read<MunroState>();
    final UserState userState = context.read<UserState>();
    try {
      // Load necessary data
      await context.read<SettingsState>().load();
      await userState.readUser(uid: context.read<AuthState>().currentUserId);
      await context.read<SavedListState>().readUserSavedLists();

      munroState.setSelectedMunroId = munroId;
      var munro = munroState.munroList.firstWhere(
        (munro) => munro.id == munroId,
        orElse: () => Munro.empty,
      );
      munroState.setSelectedMunro = munro;

      navigatorKey.currentState!.pushNamed(
        MunroScreen.route,
      );

      navigatorKey.currentState!.pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, __, ___) => const MunroScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );

      // If I want to always open the munro over the map. If not then the above works fine but it could open munros over the feed etc. Do we care?

      // navigatorKey.currentState!.pushNamedAndRemoveUntil(
      //   HomeScreen.route,
      //   (route) => false,
      // );

      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   navigatorKey.currentState!.pushNamed(MunroScreen.route);
      // });
    } catch (e) {
      print('Error handling Branch link: $e');
    }
  }

  static Future<void> shareMunro(BuildContext context, String munroName, int munroId) async {
    // Log share event
    context.read<Analytics>().track(AnalyticsEvent.munroShared, props: {
      AnalyticsProp.munroId: munroId,
      AnalyticsProp.munroName: munroName,
    });

    // Create a Branch link
    try {
      final BranchUniversalObject buo = BranchUniversalObject(
        canonicalIdentifier: 'munro/$munroId',
        title: 'Check out this Munro!',
        contentDescription: 'Explore the details for this Munro.',
        contentMetadata: BranchContentMetaData()..addCustomMetadata('munroId', munroId),
        publiclyIndex: true,
        locallyIndex: true,
      );

      final BranchLinkProperties linkProperties = BranchLinkProperties(
        channel: 'app',
        feature: 'sharing',
        stage: 'user_share',
        tags: ['munro', 'explore'],
      );

      final BranchResponse response = await FlutterBranchSdk.getShortUrl(
        buo: buo,
        linkProperties: linkProperties,
      );

      if (response.success && response.result != null) {
        await SharePlus.instance.share(ShareParams(text: 'Check out $munroName - ${response.result}'));
      } else {
        throw Exception('Branch link creation failed: ${response.errorMessage}');
      }
    } catch (e) {
      showSnackBar(context, 'Failed to share link.');
    }
  }

  static void dispose() {
    _branchStreamSubscription?.cancel();
  }
}
