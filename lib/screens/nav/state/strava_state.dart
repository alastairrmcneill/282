import 'package:material_ui/material_ui.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/strava/helpers/match_strava_activity.dart';

const _stravaCallbackUrlScheme = 'twoeightwo';

class StravaState extends ChangeNotifier {
  final StravaConnectionsRepository _stravaConnectionsRepository;
  final StravaMatchingConfigRepository _stravaMatchingConfigRepository;
  final MunroState _munroState;
  final Logger _logger;

  StravaState(
    this._stravaConnectionsRepository,
    this._stravaMatchingConfigRepository,
    this._munroState,
    this._logger,
  );
  StravaConnectionStatus _connectionStatus = StravaConnectionStatus.initial;
  StravaScanningStatus _scanningStatus = StravaScanningStatus.initial;
  List<StravaActivity> _activities = [];
  int _activitiesScannedCount = 0;
  List<StravaMunroMatch> _matches = [];
  List<StravaMunroMatch> _selectedMatches = [];

  StravaConnectionStatus get connectionStatus => _connectionStatus;
  StravaScanningStatus get scanningStatus => _scanningStatus;
  List<StravaActivity> get activities => _activities;
  int get activitiesScannedCount => _activitiesScannedCount;
  List<StravaMunroMatch> get matches => _matches;
  List<StravaMunroMatch> get selectedMatches => _selectedMatches;

  Future<StravaConnectionStatus> getStravaConnectionStatus({required String userId}) async {
    try {
      final stravaConnection = await _stravaConnectionsRepository.stravaConnectionForUser(userId: userId);
      print("🎯 ~ StravaState ~ getStravaConnectionStatus ~ stravaConnection: $stravaConnection");
      _connectionStatus = stravaConnection != null && stravaConnection.revokedAt == null
          ? StravaConnectionStatus.connected
          : StravaConnectionStatus.disconnected;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _connectionStatus = StravaConnectionStatus.error;
      notifyListeners();
    }
    return _connectionStatus;
  }

  // Opens the Strava OAuth flow and suspends until the strava-connect edge
  // function redirects back to the app, so callers only resume once the
  // user has actually finished (or abandoned) the browser flow.
  Future<StravaConnectionStatus> connectWithStrava({required String userId}) async {
    final authUrl = Uri.https('www.strava.com', '/oauth/authorize', {
      'client_id': '270263',
      'redirect_uri': 'https://pqgaczyxzxopkgyjqudk.supabase.co/functions/v1/strava-connect',
      'response_type': 'code',
      'approval_prompt': 'force',
      'scope': 'activity:read_all',
      'state': userId,
    });

    try {
      final callback = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _stravaCallbackUrlScheme,
      );
      final status = Uri.parse(callback).queryParameters['status'];
      if (status != 'success') {
        _logger.error('Strava OAuth callback did not report success: $callback');
        _connectionStatus = StravaConnectionStatus.error;
        notifyListeners();
        return _connectionStatus;
      }
    } catch (error, stackTrace) {
      // User likely dismissed the browser before completing the flow.
      _logger.error('Strava OAuth flow did not complete', stackTrace: stackTrace);
      _connectionStatus = StravaConnectionStatus.error;
      notifyListeners();
      return _connectionStatus;
    }

    return await getStravaConnectionStatus(userId: userId);
  }

  Future<void> startHistoricalScan() async {
    _scanningStatus = StravaScanningStatus.loading;
    notifyListeners();

    final response = await Supabase.instance.client.functions.invoke('strava-scan-activities');

    _activities = (response.data as List<dynamic>).map((r) => StravaActivity.fromJSON(r)).toList();
    _scanningStatus = StravaScanningStatus.scanning;
    notifyListeners();

    final matchingConfig = await _stravaMatchingConfigRepository.getStravaMatchingConfig();

    for (StravaActivity activity in _activities) {
      await Future.delayed(const Duration(milliseconds: 20));
      final matches = matchStravaActivity(
        activity: activity,
        config: matchingConfig,
        munros: _munroState.munroList,
      );

      _matches.insertAll(0, matches);
      _selectedMatches.insertAll(0, matches);
      _activitiesScannedCount++;
      notifyListeners();
    }

    _scanningStatus = StravaScanningStatus.completed;
    notifyListeners();
  }

  void toggleMatchSelection(StravaMunroMatch match) {
    if (_selectedMatches.contains(match)) {
      _selectedMatches.remove(match);
    } else {
      _selectedMatches.add(match);
    }
    notifyListeners();
  }
}

enum StravaConnectionStatus { initial, connected, disconnected, error }

enum StravaScanningStatus { initial, loading, scanning, completed, error }
