import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';

class ProfileState extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.initial;
  AppUser? _user;
  List<AppUser> _navigationHistory = [];
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  Error _error = Error();

  AppUser? get user => _user;
  ProfileStatus get status => _status;
  bool get isFollowing => _isFollowing;
  bool get isCurrentUser => _isCurrentUser;
  Error get error => _error;

  set setStatus(ProfileStatus profileStatus) {
    _status = profileStatus;
    notifyListeners();
  }

  set setUser(AppUser? user) {
    if (user != null) {
      _navigationHistory.insert(0, user);
    }
    _user = user;
    notifyListeners();
  }

  void navigateBack() {
    if (_navigationHistory.isNotEmpty) {
      _navigationHistory.removeAt(0);
      if (_navigationHistory.isNotEmpty) {
        _user = _navigationHistory[0];
      } else {
        _user = null;
      }

      notifyListeners();
    }
  }

  void clear() {
    _navigationHistory = [];
    _user = null;
  }

  set setIsFollowing(bool isFollowing) {
    _isFollowing = isFollowing;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUser = isCurrentUser;
    notifyListeners();
  }

  set setError(Error error) {
    _status = ProfileStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum ProfileStatus { initial, loading, loaded, error }
