import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class DeepLinkIntent {
  final int munroId;
  const DeepLinkIntent.openMunro(this.munroId);
}

class DeepLinkState extends ChangeNotifier {
  final DeepLinkRepository _repo;
  final AppIntentState _intents;
  final Logger _logger;

  DeepLinkState(this._repo, this._intents, this._logger);

  StreamSubscription<AppIntent>? _sub;
  bool _started = false;

  Future<void> init({required bool enableLogging}) async {
    if (_started) return;
    _started = true;

    try {
      await _repo.init(enableLogging: enableLogging);
      _sub = _repo.events.listen(_intents.enqueue);
    } catch (error, stackstrace) {
      _logger.error('DeepLink init failed', error: error, stackTrace: stackstrace);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
