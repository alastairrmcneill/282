import 'package:two_eight_two/models/models.dart';

class AppSettings {
  final bool pushNotifications;
  final bool metricHeight;
  final bool metricTemperature;
  final String defaultPostVisibility;
  final String themeMode;

  AppSettings({
    required this.pushNotifications,
    required this.metricHeight,
    required this.metricTemperature,
    required this.defaultPostVisibility,
    required this.themeMode,
  });

  static AppSettings get initial => AppSettings(
        pushNotifications: true,
        metricHeight: false,
        metricTemperature: true,
        defaultPostVisibility: Privacy.public,
        themeMode: ThemeModeOption.system,
      );

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      SettingsFields.pushNotifications: pushNotifications,
      SettingsFields.metricHeight: metricHeight,
      SettingsFields.metricTemperature: metricTemperature,
      SettingsFields.defaultPostVisibility: defaultPostVisibility,
      SettingsFields.themeMode: themeMode,
    };
  }

  static AppSettings fromJSON(Map<String, dynamic> json) {
    return AppSettings(
      pushNotifications: json[SettingsFields.pushNotifications] as bool? ?? true,
      metricHeight: json[SettingsFields.metricHeight] as bool? ?? false,
      metricTemperature: json[SettingsFields.metricTemperature] as bool? ?? true,
      defaultPostVisibility: json[SettingsFields.defaultPostVisibility] as String? ?? Privacy.public,
      themeMode: json[SettingsFields.themeMode] as String? ?? ThemeModeOption.system,
    );
  }

  AppSettings copyWith({
    bool? pushNotifications,
    bool? metricHeight,
    bool? metricTemperature,
    String? defaultPostVisibility,
    String? themeMode,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      metricHeight: metricHeight ?? this.metricHeight,
      metricTemperature: metricTemperature ?? this.metricTemperature,
      defaultPostVisibility: defaultPostVisibility ?? this.defaultPostVisibility,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  String toString() {
    return """AppSettings: ${SettingsFields.pushNotifications}: $pushNotifications,
      ${SettingsFields.metricHeight}: $metricHeight,
      ${SettingsFields.metricTemperature}: $metricTemperature,
      ${SettingsFields.defaultPostVisibility}: $defaultPostVisibility,
      ${SettingsFields.themeMode}: $themeMode""";
  }
}

class SettingsFields {
  static String pushNotifications = "push_notifications";
  static String metricHeight = "metric_height";
  static String metricTemperature = "metric_temperature";
  static String defaultPostVisibility = "default_post_visibility";
  static String themeMode = "theme_mode";
}

class ThemeModeOption {
  static const String system = "system";
  static const String light = "light";
  static const String dark = "dark";
}
