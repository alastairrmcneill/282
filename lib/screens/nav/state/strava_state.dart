import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/repos/strava_connections_repo.dart';

class StravaState extends ChangeNotifier {
  final StravaConnectionsRepository _stravaConnectionsRepository;
  final Logger _logger;
  StravaState(
    this._stravaConnectionsRepository,
    this._logger,
  );
  StravaStatus _status = StravaStatus.initial;

  StravaStatus get status => _status;

  Future<StravaStatus> getStravaConnectionStatus({required String userId}) async {
    try {
      final stravaConnection = await _stravaConnectionsRepository.stravaConnectionForUser(userId: userId);
      print("🎯 ~ StravaState ~ getStravaConnectionStatus ~ stravaConnection: $stravaConnection");
      _status = stravaConnection != null && stravaConnection.revokedAt == null
          ? StravaStatus.connected
          : StravaStatus.disconnected;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = StravaStatus.error;
      notifyListeners();
    }
    return _status;
  }
}

enum StravaStatus { initial, connected, disconnected, error }
