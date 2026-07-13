import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}
