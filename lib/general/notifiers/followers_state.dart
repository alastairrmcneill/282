import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class FollowersState extends ChangeNotifier {
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
    _followers.addAll(followers);
    notifyListeners();
  }

  set setFollowing(List<FollowingRelationship> following) {
    _followingHistory.insert(0, following);
    _following = following;
    notifyListeners();
  }

  set addFollowing(List<FollowingRelationship> following) {
    _followingHistory[0].addAll(following);
    _following.addAll(following);
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
}

enum FollowersStatus { initial, loading, loaded, paginating, error }
