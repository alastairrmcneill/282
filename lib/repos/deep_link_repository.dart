import 'dart:async';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:two_eight_two/models/models.dart';

class BranchLinkClick {
  const BranchLinkClick({
    required this.canonicalIdentifier,
    required this.channel,
    required this.campaign,
    required this.feature,
    required this.routed,
  });

  final String? canonicalIdentifier;
  final String? channel;
  final String? campaign;
  final String? feature;

  final bool routed;
}

class DeepLinkRepository {
  StreamSubscription<Map>? _sub;
  final _controller = StreamController<NavigationIntent>.broadcast();
  final _clicks = StreamController<BranchLinkClick>.broadcast();

  Stream<NavigationIntent> get events => _controller.stream;

  Stream<BranchLinkClick> get clicks => _clicks.stream;

  Future<void> init({
    required bool enableLogging,
    void Function(Object error, StackTrace stackTrace)? onSessionError,
  }) async {
    await FlutterBranchSdk.init(
      enableLogging: enableLogging,
      branchAttributionLevel: BranchAttributionLevel.FULL,
    );

    _sub = FlutterBranchSdk.listSession().listen(
      (data) {
        final clicked = data['+clicked_branch_link'] == true;
        if (!clicked) return;

        final canonicalIdentifier = data['~canonical_identifier'] as String?;
        final intent = _intentFor(canonicalIdentifier, data);

        _clicks.add(
          BranchLinkClick(
            canonicalIdentifier: canonicalIdentifier,
            channel: data['~channel'] as String?,
            campaign: data['~campaign'] as String?,
            feature: data['~feature'] as String?,
            routed: intent != null,
          ),
        );

        if (intent != null) _controller.add(intent);
      },
      onError: (Object error, StackTrace stackTrace) {
        onSessionError?.call(error, stackTrace);
      },
    );
  }

  NavigationIntent? _intentFor(String? canonicalIdentifier, Map data) {
    if (canonicalIdentifier == null) return null;

    if (canonicalIdentifier.startsWith('munro/')) {
      final munroIdRaw = data['munroId'];
      final munroId = munroIdRaw is int ? munroIdRaw : int.tryParse('$munroIdRaw');

      if (munroId != null && munroId > 0) {
        return OpenMunroIntent(munroId: munroId);
      }
    }
    return null;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
    await _clicks.close();
  }
}
