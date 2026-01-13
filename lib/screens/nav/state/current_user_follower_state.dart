import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CurrentUserFollowerState extends ChangeNotifier {
  final FollowersRepository _repository;
  final UserState _userState;
  final Logger _logger;

  CurrentUserFollowerState(
    this._repository,
    this._userState,
    this._logger,
  );

  CurrentUserFollowerStatus _status = CurrentUserFollowerStatus.initial;
  Error _error = Error();
  Set<String> _followingIds = {};

  CurrentUserFollowerStatus get status => _status;
  Error get error => _error;

  bool isFollowing(String targetUserId) => _followingIds.contains(targetUserId);

  Future<void> loadInitial() async {
    _status = CurrentUserFollowerStatus.loading;
    notifyListeners();

    try {
      if (_userState.currentUser == null) {
        _status = CurrentUserFollowerStatus.loaded;
        notifyListeners();
        return;
      }

      final followingUsers = await _repository.getAllFollowingFromUid(
        sourceId: _userState.currentUser?.uid ?? "",
        excludedUserIds: _userState.blockedUsers,
      );

      _followingIds = followingUsers.map((following) => following.targetId).toSet();
      _status = CurrentUserFollowerStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = CurrentUserFollowerStatus.error;
      _error = Error(message: "There was an issue loading your followers. Please try again.");
      notifyListeners();
    }
  }

  Future<void> followUser({required String targetUserId}) async {
    try {
      if (_userState.currentUser == null) return;

      _status = CurrentUserFollowerStatus.loading;
      notifyListeners();

      FollowingRelationship followingRelationship = FollowingRelationship(
        sourceId: _userState.currentUser!.uid ?? "",
        targetId: targetUserId,
      );
      await _repository.create(followingRelationship: followingRelationship);

      _followingIds.add(targetUserId);

      _status = CurrentUserFollowerStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue following this user. Please try again.");
    }
  }

  Future<void> unfollowUser({required String targetUserId}) async {
    try {
      if (_userState.currentUser == null) return;

      _status = CurrentUserFollowerStatus.loading;
      notifyListeners();

      await _repository.delete(
        sourceId: _userState.currentUser!.uid ?? "",
        targetId: targetUserId,
      );

      _followingIds.remove(targetUserId);

      _status = CurrentUserFollowerStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue unfollowing this user. Please try again.");
    }
  }

  set setStatus(CurrentUserFollowerStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = CurrentUserFollowerStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = CurrentUserFollowerStatus.initial;
    _error = Error();
    _followingIds = {};
  }
}

enum CurrentUserFollowerStatus { initial, loading, loaded, error }
