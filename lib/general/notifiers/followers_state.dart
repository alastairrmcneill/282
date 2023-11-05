import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class FollowersState extends ChangeNotifier {
  FollowersStatus _status = FollowersStatus.initial;
  List<FollowingRelationship> _followers = [];
  List<FollowingRelationship> _following = [];

  FollowersStatus get status => _status;
  List<FollowingRelationship> get followers => _followers;
  List<FollowingRelationship> get following => _following;

  set setStatus(FollowersStatus followersStatus) {
    _status = followersStatus;
    notifyListeners();
  }

  set setFollowers(List<FollowingRelationship> followers) {
    _followers = followers;
    notifyListeners();
  }

  set setFollowing(List<FollowingRelationship> following) {
    _following = following;
    notifyListeners();
  }
}

enum FollowersStatus { initial, loading, loaded, error }
