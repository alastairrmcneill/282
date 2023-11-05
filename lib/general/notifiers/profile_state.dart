import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class ProfileState extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.initial;
  AppUser? _user;
  bool _isFollowing = false;
  bool _isCurrentUser = false;

  AppUser? get user => _user;
  ProfileStatus get status => _status;
  bool get isFollowing => _isFollowing;
  bool get isCurrentUser => _isCurrentUser;

  set setStatus(ProfileStatus profileStatus) {
    _status = profileStatus;
    notifyListeners();
  }

  set setUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  set setIsFollowing(bool isFollowing) {
    _isFollowing = isFollowing;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUser = isCurrentUser;
    notifyListeners();
  }
}

enum ProfileStatus { initial, loading, loaded, error }
