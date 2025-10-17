import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class DeepLinkService {
  static StreamSubscription<Map>? _branchStreamSubscription;

  static Future<void> initBranchLinks({required GlobalKey<NavigatorState> navigatorKey, required String flavor}) async {
    await FlutterBranchSdk.init(
      enableLogging: flavor != "Production",
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
    AnalyticsService.logEvent(
      name: 'branch_link_clicked',
      parameters: {
        'munro_id': (munroId ?? 0).toString(),
      },
    );

    if (munroId == null || munroId == 0) return;

    final BuildContext context = navigatorKey.currentContext!;
    final MunroState munroState = Provider.of<MunroState>(context, listen: false);

    try {
      // Load necessary data
      await SettingsSerivce.loadSettings(context);
      await UserService.readCurrentUser(context);
      await SavedListService.readUserSavedLists(context);

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
    AnalyticsService.logEvent(
      name: 'munro_shared',
      parameters: {
        'munro_id': munroId.toString(),
        'munro_name': munroName,
      },
    );

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
