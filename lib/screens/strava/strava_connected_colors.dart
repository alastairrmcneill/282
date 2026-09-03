import 'package:flutter/material.dart';

/// Fixed dark-mode-only palette for the Strava-connected celebration screen.
/// Not theme colors — this screen ignores light/dark mode by design.
abstract class StravaConnectedColors {
  static const background = Color(0xFF052E22);
  static const surface = Color(0x12FFFFFF); // white @ 7%
  static const border = Color(0x21FFFFFF); // white @ 13%
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSubtitle = Color(0xBFFFFFFF); // white @ 75%
  static const textMuted = Color(0x8CFFFFFF); // white @ 55%
  static const accentText = Color(0xFF6EE7B7); // emerald-300
}
