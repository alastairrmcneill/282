import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class NavigationState extends ChangeNotifier {
  NavigationStatus _status = NavigationStatus.initial;
  Error _error = Error();
  String _navigateToRoute = "";

  NavigationStatus get status => _status;
  Error get error => _error;
  String get navigateToRoute => _navigateToRoute;

  set setNavigateToRoute(String navigateToRoute) {
    _navigateToRoute = navigateToRoute;
    notifyListeners();
  }

  set setStatus(NavigationStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = NavigationStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum NavigationStatus { initial, loading, loaded, error }
