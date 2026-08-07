import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/analytics/analytics.dart';
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
  final NavigationIntentState _intents;
  final Analytics _analytics;
  final Logger _logger;

  DeepLinkState(this._repo, this._intents, this._analytics, this._logger);

  StreamSubscription<NavigationIntent>? _sub;
  StreamSubscription<BranchLinkClick>? _clickSub;
  bool _started = false;

  Future<void> init({required bool enableLogging}) async {
    if (_started) return;
    _started = true;

    try {
      await _repo.init(
        enableLogging: enableLogging,
        onSessionError: (error, stackTrace) {
          // Branch attribution data failed to arrive for this session (e.g.
          // the native SDK timed out initializing, or there's no network) —
          // deep link click tracking is unavailable, but this must never
          // crash the app or be treated as a fatal, unresolved error.
          _logger.info('Branch session listener error (non-fatal): $error');
        },
      );

      _clickSub = _repo.clicks.listen((click) {
        _analytics.track(
          AnalyticsEvent.branchLinkClicked,
          props: {
            AnalyticsProp.linkType: click.canonicalIdentifier,
            AnalyticsProp.channel: click.channel,
            AnalyticsProp.campaign: click.campaign,
            AnalyticsProp.feature: click.feature,
            AnalyticsProp.routed: click.routed,
          },
        );
      });

      _sub = _repo.events.listen(_intents.enqueue);
    } catch (error, stackstrace) {
      _logger.error('DeepLink init failed', error: error, stackTrace: stackstrace);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _clickSub?.cancel();
    super.dispose();
  }
}
