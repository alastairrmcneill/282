import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/log_service.dart';

class FollowersListState extends ChangeNotifier {
  final FollowersRepository _repository;
  final UserState _userState;
  FollowersListState(
    this._repository,
    this._userState,
  );

  FollowersListStatus _status = FollowersListStatus.initial;
  List<FollowingRelationship> _followers = [];
  List<FollowingRelationship> _following = [];
  Error _error = Error();

  FollowersListStatus get status => _status;
  List<FollowingRelationship> get followers => _followers;
  List<FollowingRelationship> get following => _following;
  Error get error => _error;

  Future<void> loadInitialFollowersAndFollowing({required String userId}) async {
    UserState userState = _userState;

    List<String> blockedUsers = userState.blockedUsers;

    try {
      _status = FollowersListStatus.loading;
      notifyListeners();

      // Load followers from database
      _followers = await _repository.getFollowersFromUid(
        targetId: userId,
        excludedUserIds: blockedUsers,
      );

      // Load following from database
      _following = await _repository.getFollowingFromUid(
        sourceId: userId,
        excludedUserIds: blockedUsers,
      );

      _status = FollowersListStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue. Please try again.");
    }
  }

  Future<void> paginateFollowers({required String userId}) async {
    UserState userState = _userState;

    List<String> blockedUsers = userState.blockedUsers;

    try {
      _status = FollowersListStatus.paginating;
      notifyListeners();

      // Add followers from database
      _followers.addAll(await _repository.getFollowersFromUid(
        targetId: userId,
        excludedUserIds: blockedUsers,
        offset: _followers.length,
      ));

      _status = FollowersListStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue. Please try again.");
    }
  }

  Future<void> paginateFollowing({required String userId}) async {
    UserState userState = _userState;

    List<String> blockedUsers = userState.blockedUsers;

    try {
      _status = FollowersListStatus.paginating;
      notifyListeners();

      // Add followers from database
      _following.addAll(await _repository.getFollowingFromUid(
        sourceId: userId,
        excludedUserIds: blockedUsers,
        offset: _following.length,
      ));

      _status = FollowersListStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue. Please try again.");
    }
  }

  set setStatus(FollowersListStatus followersListStatus) {
    _status = followersListStatus;
    notifyListeners();
  }

  set setFollowers(List<FollowingRelationship> followers) {
    _followers = followers;
    notifyListeners();
  }

  set addFollowers(List<FollowingRelationship> followers) {
    _followers.addAll(followers);
    notifyListeners();
  }

  set setFollowing(List<FollowingRelationship> following) {
    _following = following;
    notifyListeners();
  }

  set addFollowing(List<FollowingRelationship> following) {
    _following.addAll(following);
    notifyListeners();
  }

  void clear() {
    _followers = [];
    _following = [];
  }

  set setError(Error error) {
    _status = FollowersListStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _status = FollowersListStatus.initial;
    _error = Error();
    clear();
  }
}

enum FollowersListStatus { initial, loading, loaded, paginating, followLoading, followLoaded, error }
