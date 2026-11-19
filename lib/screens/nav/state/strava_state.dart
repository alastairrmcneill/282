import 'package:material_ui/material_ui.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

const _stravaCallbackUrlScheme = 'twoeightwo';
const _scanRevealSteps = 40;

class StravaState extends ChangeNotifier {
  final StravaConnectionsRepository _stravaConnectionsRepository;
  final StravaFunctionsRepository _stravaFunctionsRepository;
  final StravaActivitiesRepository _stravaActivitiesRepository;
  final MunroState _munroState;
  final Logger _logger;

  StravaState(
    this._stravaConnectionsRepository,
    this._stravaFunctionsRepository,
    this._stravaActivitiesRepository,
    this._munroState,
    this._logger,
  );

  StravaConnectionStatus _connectionStatus = StravaConnectionStatus.initial;
  StravaConnection? _connection;
  StravaScanningStatus _scanningStatus = StravaScanningStatus.initial;
  int _activitiesTotal = 0;
  int _activitiesScannedCount = 0;
  bool _scanComplete = true;
  List<StravaMunroMatch> _matches = [];
  List<StravaMunroMatch> _selectedMatches = [];
  List<StravaActivity> _cachedActivities = [];
  StravaDataDeletion? _latestDeletion;
  Error _error = Error();

  StravaConnectionStatus get connectionStatus => _connectionStatus;
  StravaConnection? get connection => _connection;
  StravaScanningStatus get scanningStatus => _scanningStatus;
  int get activitiesTotal => _activitiesTotal;
  int get activitiesScannedCount => _activitiesScannedCount;
  bool get scanComplete => _scanComplete;
  List<StravaMunroMatch> get matches => _matches;
  List<StravaMunroMatch> get selectedMatches => _selectedMatches;
  List<StravaActivity> get cachedActivities => _cachedActivities;
  StravaDataDeletion? get latestDeletion => _latestDeletion;
  Error get error => _error;

  Future<StravaConnectionStatus> getStravaConnectionStatus({required String userId}) async {
    try {
      _connection = await _stravaConnectionsRepository.stravaConnectionForUser(userId: userId);
      _connectionStatus = _connection != null && _connection!.revokedAt == null
          ? StravaConnectionStatus.connected
          : StravaConnectionStatus.disconnected;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error('Failed to load Strava connection', error: error, stackTrace: stackTrace);
      _connectionStatus = StravaConnectionStatus.error;
      notifyListeners();
    }
    return _connectionStatus;
  }

  // Opens the Strava OAuth flow and suspends until the strava-connect edge
  // function redirects back to the app, so callers only resume once the
  // user has actually finished (or abandoned) the browser flow.
  Future<StravaConnectionStatus> connectWithStrava({required String userId}) async {
    try {
      final authUrl = await _stravaFunctionsRepository.oauthStartUrl();
      final callback = await FlutterWebAuth2.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: _stravaCallbackUrlScheme,
      );
      final params = Uri.parse(callback).queryParameters;
      final status = params['status'];
      if (status == 'cancelled') {
        _connectionStatus = StravaConnectionStatus.disconnected;
        notifyListeners();
        return _connectionStatus;
      }
      if (status != 'success') {
        _logger.error('Strava OAuth callback did not report success', context: {'status': status});
        _error = Error(message: params['message'] ?? 'Could not connect to Strava. Please try again.');
        _connectionStatus = StravaConnectionStatus.error;
        notifyListeners();
        return _connectionStatus;
      }
    } catch (error, stackTrace) {
      // Usually the user dismissing the browser before finishing.
      _logger.error('Strava OAuth flow did not complete', error: error, stackTrace: stackTrace);
      _connectionStatus = StravaConnectionStatus.disconnected;
      notifyListeners();
      return _connectionStatus;
    }

    return await getStravaConnectionStatus(userId: userId);
  }

  /// Revokes access on Strava and permanently deletes everything 282 holds
  /// from Strava. Returns the server's confirmation, or null on failure.
  Future<StravaDataDeletion?> disconnectAndDeleteData() async {
    try {
      final deletion = await _stravaFunctionsRepository.disconnectAndDelete();
      _latestDeletion = deletion;
      _connection = null;
      _cachedActivities = [];
      _matches = [];
      _selectedMatches = [];
      _connectionStatus = StravaConnectionStatus.disconnected;
      notifyListeners();
      return deletion;
    } catch (error, stackTrace) {
      _logger.error('Failed to disconnect Strava', error: error, stackTrace: stackTrace);
      _error = Error(message: "We couldn't disconnect Strava. Please try again.");
      notifyListeners();
      return null;
    }
  }

  Future<void> loadStoredData({required String userId}) async {
    try {
      final results = await Future.wait([
        _stravaConnectionsRepository.stravaConnectionForUser(userId: userId),
        _stravaActivitiesRepository.cachedActivitiesForUser(userId: userId),
        _stravaConnectionsRepository.latestDeletionForUser(userId: userId),
      ]);
      _connection = results[0] as StravaConnection?;
      _cachedActivities = results[1] as List<StravaActivity>;
      _latestDeletion = results[2] as StravaDataDeletion?;
      _connectionStatus = _connection != null && _connection!.revokedAt == null
          ? StravaConnectionStatus.connected
          : StravaConnectionStatus.disconnected;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error('Failed to load stored Strava data', error: error, stackTrace: stackTrace);
      _error = Error(message: "We couldn't load your Strava data. Please try again.");
      notifyListeners();
    }
  }

  Future<void> startHistoricalScan() async {
    _scanningStatus = StravaScanningStatus.loading;
    _matches = [];
    _selectedMatches = [];
    _activitiesTotal = 0;
    _activitiesScannedCount = 0;
    _error = Error();
    notifyListeners();

    final StravaScanResult result;
    try {
      result = await _stravaFunctionsRepository.scanActivities();
    } on FunctionException catch (error, stackTrace) {
      _logger.error('Strava scan failed', error: error, stackTrace: stackTrace, context: {'status': error.status});
      _error = Error(
        message: switch (error.status) {
          429 => "You've already scanned your Strava history today. New walks are still checked automatically.",
          503 => 'Strava is busy right now. Please try again in a little while.',
          _ => "We couldn't finish scanning your Strava activities. Please try again.",
        },
      );
      _scanningStatus = StravaScanningStatus.error;
      notifyListeners();
      return;
    } catch (error, stackTrace) {
      _logger.error('Strava scan failed', error: error, stackTrace: stackTrace);
      _error = Error(message: "We couldn't finish scanning your Strava activities. Please try again.");
      _scanningStatus = StravaScanningStatus.error;
      notifyListeners();
      return;
    }

    final munrosById = {for (final munro in _munroState.munroList) munro.id: munro};
    final allMatches = result.matches
        .where((m) => munrosById.containsKey(m.munroId))
        .map((m) => StravaMunroMatch(munro: munrosById[m.munroId]!, stravaActivity: m.activity))
        .toList();

    _activitiesTotal = result.activitiesScanned;
    _scanComplete = result.complete;
    _scanningStatus = StravaScanningStatus.scanning;
    notifyListeners();

    // Matching already happened on the server; reveal results progressively.
    var revealed = 0;
    for (var step = 1; step <= _scanRevealSteps; step++) {
      await Future.delayed(const Duration(milliseconds: 30));
      final target = (allMatches.length * step / _scanRevealSteps).floor();
      final batch = allMatches.sublist(revealed, target);
      revealed = target;
      _matches.insertAll(0, batch);
      _selectedMatches.insertAll(0, batch);
      _activitiesScannedCount = (_activitiesTotal * step / _scanRevealSteps).floor();
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
