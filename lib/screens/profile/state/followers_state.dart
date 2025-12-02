import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/log_service.dart';

class FollowersState extends ChangeNotifier {
  final FollowingRelationshipsRepository _repository;
  final UserState _userState;
  final ProfileState _profileState;
  FollowersState(
    this._repository,
    this._userState,
    this._profileState,
  );

  FollowersStatus _status = FollowersStatus.initial;
  List<FollowingRelationship> _followers = [];
  List<FollowingRelationship> _following = [];
  List<List<FollowingRelationship>> _followersHistory = [];
  List<List<FollowingRelationship>> _followingHistory = [];
  Error _error = Error();

  FollowersStatus get status => _status;
  List<FollowingRelationship> get followers => _followers;
  List<FollowingRelationship> get following => _following;
  Error get error => _error;

  Future<void> followUser({required String targetUserId}) async {
    try {
      if (_userState.currentUser == null) {
        return;
      }
      _status = FollowersStatus.followLoading;
      notifyListeners();

      FollowingRelationship followingRelationship = FollowingRelationship(
        sourceId: _userState.currentUser!.uid ?? "",
        targetId: targetUserId,
      );
      await _repository.create(followingRelationship: followingRelationship);

      if (_profileState.profile == null) {
        _status = FollowersStatus.followLoaded;
        notifyListeners();
        return;
      }

      Profile tempProfile =
          _profileState.profile!.copyWith(followersCount: (_profileState.profile?.followersCount ?? 0) + 1);
      _profileState.setProfile = tempProfile;
      _profileState.setIsFollowing = true;
      _status = FollowersStatus.followLoaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue following this user. Please try again.");
    }
  }

  Future<void> unfollowUser({required String targetUserId}) async {
    try {
      if (_userState.currentUser == null) {
        return;
      }
      _status = FollowersStatus.followLoading;
      notifyListeners();

      await _repository.delete(
        sourceId: _userState.currentUser!.uid ?? "",
        targetId: targetUserId,
      );

      if (_profileState.profile == null) {
        _status = FollowersStatus.followLoaded;
        notifyListeners();
        return;
      }

      Profile tempProfile =
          _profileState.profile!.copyWith(followersCount: (_profileState.profile?.followersCount ?? 0) - 1);
      _profileState.setProfile = tempProfile;
      _profileState.setIsFollowing = false;
      _status = FollowersStatus.followLoaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue unfollowing this user. Please try again.");
    }
  }

  Future<void> loadInitialFollowersAndFollowing({required String userId}) async {
    UserState userState = _userState;

    List<String> blockedUsers = userState.blockedUsers;

    try {
      _status = FollowersStatus.loading;
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

      _status = FollowersStatus.loaded;
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
      _status = FollowersStatus.paginating;
      notifyListeners();

      // Add followers from database
      _followers.addAll(await _repository.getFollowersFromUid(
        targetId: userId,
        excludedUserIds: blockedUsers,
        offset: _followers.length,
      ));

      _status = FollowersStatus.loaded;
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
      _status = FollowersStatus.paginating;
      notifyListeners();

      // Add followers from database
      _following.addAll(await _repository.getFollowingFromUid(
        sourceId: userId,
        excludedUserIds: blockedUsers,
        offset: _following.length,
      ));

      _status = FollowersStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue. Please try again.");
    }
  }

  set setStatus(FollowersStatus followersStatus) {
    _status = followersStatus;
    notifyListeners();
  }

  set setFollowers(List<FollowingRelationship> followers) {
    _followersHistory.insert(0, followers);
    _followers = followers;
    notifyListeners();
  }

  set addFollowers(List<FollowingRelationship> followers) {
    _followersHistory[0].addAll(followers);
    // _followers.addAll(followers);
    notifyListeners();
  }

  set setFollowing(List<FollowingRelationship> following) {
    _followingHistory.insert(0, following);
    _following = following;
    notifyListeners();
  }

  set addFollowing(List<FollowingRelationship> following) {
    _followingHistory[0].addAll(following);
    // _following.addAll(following);
    notifyListeners();
  }

  void navigateBack() {
    if (_followersHistory.isNotEmpty && _followingHistory.isNotEmpty) {
      _followersHistory.removeAt(0);
      _followingHistory.removeAt(0);

      if (_followersHistory.isNotEmpty) {
        _followers = _followersHistory[0];
      } else {
        _followers = [];
      }

      if (_followingHistory.isNotEmpty) {
        _following = _followingHistory[0];
      } else {
        _following = [];
      }
      notifyListeners();
    }
  }

  void clear() {
    _followersHistory = [];
    _followingHistory = [];
    _followers = [];
    _following = [];
  }

  set setError(Error error) {
    _status = FollowersStatus.error;
    _error = error;
    notifyListeners();
  }

  reset() {
    _status = FollowersStatus.initial;
    _error = Error();
    clear();
  }
}

enum FollowersStatus { initial, loading, loaded, paginating, followLoading, followLoaded, error }
