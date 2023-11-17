import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class UserState extends ChangeNotifier {
  UserStatus _status = UserStatus.initial;
  Error _error = Error();
  AppUser? _currentUser;

  UserStatus get status => _status;
  Error get error => _error;
  AppUser? get currentUser => _currentUser;

  set setStatus(UserStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = UserStatus.error;
    _error = error;
    notifyListeners();
  }

  set setCurrentUser(AppUser? appUser) {
    _currentUser = appUser;
    notifyListeners();
  }
}

enum UserStatus { initial, loading, loaded, error }
