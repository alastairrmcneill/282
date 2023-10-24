import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  String _navigateToRoute = "";

  String get navigateToRoute => _navigateToRoute;

  set setNavigateToRoute(String navigateToRoute) {
    _navigateToRoute = navigateToRoute;
    notifyListeners();
  }
}
