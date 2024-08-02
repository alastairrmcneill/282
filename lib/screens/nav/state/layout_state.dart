import 'package:flutter/material.dart';

class LayoutState extends ChangeNotifier {
  double _bottomNavBarHeight = 0;

  get bottomNavBarHeight => _bottomNavBarHeight;

  set setBottomNavBarHeight(double bottomNavBarHeight) {
    _bottomNavBarHeight = bottomNavBarHeight;
    notifyListeners();
  }
}
