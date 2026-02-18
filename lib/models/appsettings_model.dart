import 'package:two_eight_two/models/models.dart';

class AppSettings {
  final bool pushNotifications;
  final bool metricHeight;
  final bool metricTemperature;
  final String defaultPostVisibility;
  AppSettings({
    required this.pushNotifications,
    required this.metricHeight,
    required this.metricTemperature,
    required this.defaultPostVisibility,
  });

  static AppSettings get initial => AppSettings(
        pushNotifications: true,
        metricHeight: false,
        metricTemperature: true,
        defaultPostVisibility: Privacy.public,
      );

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      SettingsFields.pushNotifications: pushNotifications,
      SettingsFields.metricHeight: metricHeight,
      SettingsFields.metricTemperature: metricTemperature,
      SettingsFields.defaultPostVisibility: defaultPostVisibility,
    };
  }

  static AppSettings fromJSON(Map<String, dynamic> json) {
    return AppSettings(
      pushNotifications: json[SettingsFields.pushNotifications] as bool? ?? true,
      metricHeight: json[SettingsFields.metricHeight] as bool? ?? false,
      metricTemperature: json[SettingsFields.metricTemperature] as bool? ?? true,
      defaultPostVisibility: json[SettingsFields.defaultPostVisibility] as String? ?? Privacy.public,
    );
  }

  AppSettings copyWith({
    bool? pushNotifications,
    bool? metricHeight,
    bool? metricTemperature,
    String? defaultPostVisibility,
  }) {
    return AppSettings(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      metricHeight: metricHeight ?? this.metricHeight,
      metricTemperature: metricTemperature ?? this.metricTemperature,
      defaultPostVisibility: defaultPostVisibility ?? this.defaultPostVisibility,
    );
  }

  @override
  String toString() {
    return """AppSettings: ${SettingsFields.pushNotifications}: $pushNotifications,
      ${SettingsFields.metricHeight}: $metricHeight,
      ${SettingsFields.metricTemperature}: $metricTemperature,
      ${SettingsFields.defaultPostVisibility}: $defaultPostVisibility""";
  }
}

class SettingsFields {
  static String pushNotifications = "push_notifications";
  static String metricHeight = "metric_height";
  static String metricTemperature = "metric_temperature";
  static String defaultPostVisibility = "default_post_visibility";
}
