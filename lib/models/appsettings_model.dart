import 'package:two_eight_two/models/models.dart';

class AppSettings {
  final bool pushNotifications;
  final bool metricHeight;
  final bool metricTemperature;
  final String defaultPostVisibility;
  final String themeMode;
  final String mapStyle;

  AppSettings({
    required this.pushNotifications,
    required this.metricHeight,
    required this.metricTemperature,
    required this.defaultPostVisibility,
    required this.themeMode,
    required this.mapStyle,
  });

  static AppSettings get initial => AppSettings(
        pushNotifications: true,
        metricHeight: false,
        metricTemperature: true,
        defaultPostVisibility: Privacy.public,
        themeMode: ThemeModeOption.system,
        mapStyle: MapStyleOption.classic,
      );

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      SettingsFields.pushNotifications: pushNotifications,
      SettingsFields.metricHeight: metricHeight,
      SettingsFields.metricTemperature: metricTemperature,
      SettingsFields.defaultPostVisibility: defaultPostVisibility,
      SettingsFields.themeMode: themeMode,
      SettingsFields.mapStyle: mapStyle,
    };
  }

  static AppSettings fromJSON(Map<String, dynamic> json) {
    return AppSettings(
      pushNotifications: json[SettingsFields.pushNotifications] as bool? ?? true,
      metricHeight: json[SettingsFields.metricHeight] as bool? ?? false,
      metricTemperature: json[SettingsFields.metricTemperature] as bool? ?? true,
      defaultPostVisibility: json[SettingsFields.defaultPostVisibility] as String? ?? Privacy.public,
      themeMode: json[SettingsFields.themeMode] as String? ?? ThemeModeOption.system,
      mapStyle: json[SettingsFields.mapStyle] as String? ?? MapStyleOption.classic,
    );
  }

  AppSettings copyWith({
    bool? pushNotifications,
    bool? metricHeight,
    bool? metricTemperature,
    String? defaultPostVisibility,
    String? themeMode,
    String? mapStyle,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      metricHeight: metricHeight ?? this.metricHeight,
      metricTemperature: metricTemperature ?? this.metricTemperature,
      defaultPostVisibility: defaultPostVisibility ?? this.defaultPostVisibility,
      themeMode: themeMode ?? this.themeMode,
      mapStyle: mapStyle ?? this.mapStyle,
    );
  }

  @override
  String toString() {
    return """AppSettings: ${SettingsFields.pushNotifications}: $pushNotifications,
      ${SettingsFields.metricHeight}: $metricHeight,
      ${SettingsFields.metricTemperature}: $metricTemperature,
      ${SettingsFields.defaultPostVisibility}: $defaultPostVisibility,
      ${SettingsFields.themeMode}: $themeMode,
      ${SettingsFields.mapStyle}: $mapStyle""";
  }
}

class SettingsFields {
  static String pushNotifications = "push_notifications";
  static String metricHeight = "metric_height";
  static String metricTemperature = "metric_temperature";
  static String defaultPostVisibility = "default_post_visibility";
  static String themeMode = "theme_mode";
  static String mapStyle = "map_style";
}

class ThemeModeOption {
  static const String system = "system";
  static const String light = "light";
  static const String dark = "dark";
}

class MapStyleOption {
  static const String regions = "regions";
  static const String classic = "classic";
}
