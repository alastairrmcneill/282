import 'dart:async';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:two_eight_two/models/models.dart';

class DeepLinkRepository {
  StreamSubscription<Map>? _sub;
  final _controller = StreamController<AppIntent>.broadcast();

  Stream<AppIntent> get events => _controller.stream;

  Future<void> init({required bool enableLogging}) async {
    await FlutterBranchSdk.init(
      enableLogging: enableLogging,
      branchAttributionLevel: BranchAttributionLevel.FULL,
    );

    _sub = FlutterBranchSdk.listSession().listen((data) {
      final clicked = data['+clicked_branch_link'] == true;
      if (!clicked) return;

      final munroIdRaw = data['munroId'];
      final munroId = munroIdRaw is int ? munroIdRaw : int.tryParse('$munroIdRaw');

      if (munroId == null || munroId <= 0) return;
      _controller.add(OpenMunroIntent(munroId: munroId));
    }, onError: (e) {
      // Handle errors if necessary
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}
