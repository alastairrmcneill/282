import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class ShareLinkRepository {
  Future<String> createAppLink() async {
    final buo = BranchUniversalObject(
      canonicalIdentifier: 'app',
      title: 'Check out 282!',
      contentDescription: 'Join me on 282 and discover the best of Scotland\'s mountains.',
      publiclyIndex: true,
      locallyIndex: true,
    );

    final props = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      stage: 'user_share',
      tags: ['app'],
    );

    final res = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: props);
    if (!res.success || res.result == null) {
      throw Exception('Branch link creation failed: ${res.errorMessage}');
    }
    return res.result as String;
  }

  Future<String> createMunroLink(int munroId) async {
    final buo = BranchUniversalObject(
      canonicalIdentifier: 'munro/$munroId',
      title: 'Check out this Munro!',
      contentDescription: 'Explore the details for this Munro.',
      contentMetadata: BranchContentMetaData()..addCustomMetadata('munroId', munroId),
      publiclyIndex: true,
      locallyIndex: true,
    );

    final props = BranchLinkProperties(
      channel: 'app',
      feature: 'sharing',
      stage: 'user_share',
      tags: ['munro', 'explore'],
    );

    final res = await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: props);
    if (!res.success || res.result == null) {
      throw Exception('Branch link creation failed: ${res.errorMessage}');
    }
    return res.result as String;
  }
}
