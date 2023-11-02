import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class FollowingState extends ChangeNotifier {
  bool _followingUser = false;
  List<FollowingRelationship>? _myFollowers;
  List<FollowingRelationship>? _myFollowing;

  bool get followingUser => _followingUser;
  List<FollowingRelationship>? get myFollowers => _myFollowers;
  List<FollowingRelationship>? get myFollowing => _myFollowing;

  set setFollowingUser(bool followingUser) {
    _followingUser = followingUser;
    notifyListeners();
  }

  set setMyFollowers(List<FollowingRelationship>? myFollowers) {
    _myFollowers = myFollowers;
    notifyListeners();
  }

  set setMyFollowing(List<FollowingRelationship>? myFollowing) {
    _myFollowing = myFollowing;
    notifyListeners();
  }
}
