import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class UserState extends ChangeNotifier {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  set setCurrentUser(AppUser? appUser) {
    _currentUser = appUser;
    notifyListeners();
  }
}
