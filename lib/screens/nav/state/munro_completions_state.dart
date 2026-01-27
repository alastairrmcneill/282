import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroCompletionState extends ChangeNotifier {
  final MunroCompletionsRepository repository;
  final UserState userState;
  final Analytics _analytics;
  final Logger _logger;

  MunroCompletionState(
    this.repository,
    this.userState,
    this._analytics,
    this._logger,
  );

  MunroCompletionsStatus _status = MunroCompletionsStatus.initial;
  Error _error = Error();
  List<MunroCompletion> _munroCompletions = [];

  MunroCompletionsStatus get status => _status;
  Error get error => _error;
  List<MunroCompletion> get munroCompletions => _munroCompletions;
  Set<int> get completedMunroIds => _munroCompletions.map((c) => c.munroId).toSet();

  Future<void> loadUserMunroCompletions() async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to load munro completions.'));
      return;
    }

    _status = MunroCompletionsStatus.loading;
    notifyListeners();

    try {
      _munroCompletions = await repository.getUserMunroCompletions(userId: userState.currentUser!.uid ?? "");
      _status = MunroCompletionsStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        code: error.toString(),
        message: "There was an issue loading the munro completions",
      );
      notifyListeners();
    }
  }

  Future<void> addBulkCompletions({required List<MunroCompletion> munroCompletions}) async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to add munro completions.'));
      return;
    }
    try {
      await repository.create(munroCompletions);
      _munroCompletions = [
        ..._munroCompletions,
        ...munroCompletions,
      ];
      notifyListeners();
      _analytics.track(AnalyticsEvent.bulkMunroCompletionsAdded, props: {
        AnalyticsProp.munroCompletionsAdded: munroCompletions.length,
      });
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        code: error.toString(),
        message: "There was an issue adding the munro completions",
      );
      notifyListeners();
    }
  }

  Future<void> markMunrosAsCompleted({
    required List<int> munroIds,
    required DateTime dateTimeCompleted,
    DateTime? completionDate,
    TimeOfDay? completionStartTime,
    Duration? completionDuration,
    String? postId,
  }) async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to mark munros as completed.'));
      return;
    }

    try {
      final newCompletions = munroIds
          .map(
            (id) => MunroCompletion(
              userId: userState.currentUser!.uid ?? "",
              munroId: id,
              postId: postId,
              dateTimeCompleted: dateTimeCompleted,
              completionDate: completionDate,
              completionStartTime: completionStartTime,
              completionDuration: completionDuration,
            ),
          )
          .toList();

      await repository.create(newCompletions);

      _munroCompletions = [
        ..._munroCompletions,
        ...newCompletions,
      ];
      notifyListeners();
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        code: e.toString(),
        message: 'There was an issue marking your munros as completed',
      );
      notifyListeners();
    }
  }

  Future<void> removeMunroCompletion({
    required MunroCompletion munroCompletion,
  }) async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to remove munro completions.'));
      return;
    }
    try {
      await repository.delete(munroCompletionId: munroCompletion.id ?? "");

      _munroCompletions = _munroCompletions.where((mc) => mc.id != munroCompletion.id).toList();
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        message: "There was an issue removing your munro completion",
        code: error.toString(),
      );
      notifyListeners();
    }
  }

  Future<void> removeCompletionsByMunroIdsAndPost({
    required List<int> munroIds,
    required String postId,
  }) async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to remove munro completions.'));
      return;
    }
    try {
      await repository.deleteByMunroIdsAndPostId(
        munroIds: munroIds,
        postId: postId,
      );

      _munroCompletions = _munroCompletions.where((mc) {
        final matchMunro = munroIds.contains(mc.munroId);
        final matchPost = mc.postId == postId;
        return !(matchMunro && matchPost);
      }).toList();

      notifyListeners();
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        code: e.toString(),
        message: 'There was an issue removing your munro completions',
      );
      notifyListeners();
    }
  }

  Future<void> updateMunroCompletionsByMunroIdsAndPost({
    required List<int> munroIds,
    required String postId,
    required DateTime dateTimeCompleted,
    DateTime? completionDate,
    TimeOfDay? completionStartTime,
    Duration? completionDuration,
  }) async {
    if (userState.currentUser == null) {
      setError(Error(message: 'You must be logged in to remove munro completions.'));
      return;
    }

    try {
      await repository.updateByMunroIdsAndPostId(
        munroIds: munroIds,
        postId: postId,
        dateTimeCompleted: dateTimeCompleted,
        completionDate: completionDate,
        completionStartTime: completionStartTime,
        completionDuration: completionDuration,
      );

      _munroCompletions = _munroCompletions.map((mc) {
        final matchMunro = munroIds.contains(mc.munroId);
        final matchPost = mc.postId == postId;
        if (matchMunro && matchPost) {
          return mc.copyWith(
            dateTimeCompleted: dateTimeCompleted,
            completionDate: completionDate,
            completionStartTime: completionStartTime,
            completionDuration: completionDuration,
          );
        }
        return mc;
      }).toList();

      notifyListeners();
    } catch (e, st) {
      _logger.error(e.toString(), stackTrace: st);
      _status = MunroCompletionsStatus.error;
      _error = Error(
        code: e.toString(),
        message: 'There was an issue removing your munro completions',
      );
      notifyListeners();
    }
  }

  void setError(Error error) {
    _status = MunroCompletionsStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = MunroCompletionsStatus.initial;
    _error = Error();
    _munroCompletions = [];
    notifyListeners();
  }
}

enum MunroCompletionsStatus { initial, loading, loaded, error }
