import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class DeepLinkService {
  static bool _initialLinkHandled = false;
  static StreamSubscription<Map>? _branchStreamSubscription;

  static Future<void> initBranchLinks({required GlobalKey<NavigatorState> navigatorKey, required String flavor}) async {
    await FlutterBranchSdk.init(
      enableLogging: flavor != "Production",
      branchAttributionLevel: BranchAttributionLevel.FULL,
    );

    print('Branch SDK initialized');
    FlutterBranchSdk.listSession().listen((data) {
      print('Got deep link!');
      print(data);
      if (data.containsKey('munroId')) {
        print('Munro ID: ${data['munroId']}');
      }
    });

    // _branchStreamSubscription = FlutterBranchSdk.listSession().listen(
    //   (data) {
    //     if (data.containsKey('+clicked_branch_link') && data['+clicked_branch_link'] == true) {
    //       _handleBranchLinkData(data, navigatorKey);
    //     }
    //   },
    //   onError: (error) {
    //     print('Branch deep link error: $error');
    //   },
    // );
  }

  static void _handleBranchLinkData(Map<dynamic, dynamic> data, GlobalKey<NavigatorState> navigatorKey) async {
    print("🚀 ~ DeepLinkService ~ void_handleBranchLinkData ~ data: $data");
    if (_initialLinkHandled) return;
    _initialLinkHandled = true;

    // final BuildContext context = navigatorKey.currentContext!;
    // final MunroState munroState = Provider.of<MunroState>(context, listen: false);

    // final String? munroId = data['munroId']?.toString();
    // if (munroId == null || munroId.isEmpty) return;

    // try {
    //   await SettingsSerivce.loadSettings(context);
    //   await UserService.readCurrentUser(context);
    //   await SavedListService.readUserSavedLists(context);

    //   munroState.setSelectedMunroId = munroId;
    //   await MunroService.loadMunroDetail(context, munroId: munroId);

    //   navigatorKey.currentState!.pushNamedAndRemoveUntil(
    //     HomeScreen.route,
    //     (route) => false,
    //   );

    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     navigatorKey.currentState!.pushNamed(MunroScreen.route);
    //   });
    // } catch (e) {
    //   print('Error handling Branch link: $e');
    // }
  }

  static Future<void> shareMunro(BuildContext context, String munroId) async {
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

      // if (response.success && response.result != null) {
      //   await Share.share('Check out this Munro! ${response.result}');
      // } else {
      //   throw Exception('Branch link creation failed: ${response.errorMessage}');
      // }
    } catch (e) {
      print('Failed to create or share Branch link: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share Munro link.')),
      );
    }
  }

  static void dispose() {
    _branchStreamSubscription?.cancel();
  }
}
