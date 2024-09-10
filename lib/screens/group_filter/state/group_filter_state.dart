import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class GroupFilterState extends ChangeNotifier {
  GroupFilterStatus _status = GroupFilterStatus.initial;
  Error _error = Error();
  List<FollowingRelationship> _friends = [];
  List<String> _selectedFriendsUids = [];

  GroupFilterStatus get status => _status;
  Error get error => _error;
  List<FollowingRelationship> get friends => _friends;
  List<String> get selectedFriendsUids => _selectedFriendsUids;

  set setFriends(List<FollowingRelationship> friends) {
    _friends = friends;
    notifyListeners();
  }

  set addFriends(List<FollowingRelationship> friends) {
    _friends.addAll(friends);
    notifyListeners();
  }

  addSelectedFriend(String uid) {
    _selectedFriendsUids.add(uid);
    notifyListeners();
  }

  removeSelectedFriend(String uid) {
    if (_selectedFriendsUids.contains(uid)) _selectedFriendsUids.remove(uid);
    notifyListeners();
  }

  set setStatus(GroupFilterStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = GroupFilterStatus.error;
    _error = error;
    notifyListeners();
  }

  void clearSelection() {
    _selectedFriendsUids = [];
    notifyListeners();
  }

  void reset() {
    _status = GroupFilterStatus.initial;
    _error = Error();
    _friends = [];
    _selectedFriendsUids = [];
    notifyListeners();
  }
}

enum GroupFilterStatus { initial, loading, paginating, loaded, error }
