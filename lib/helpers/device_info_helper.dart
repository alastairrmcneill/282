import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfo {
  final String deviceId;
  final String platform;
  final String osVersion;
  final String deviceModel;

  DeviceInfo({
    required this.deviceId,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
  });
}

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static DeviceInfo? _cachedInfo;

  /// Gets device information. Caches result for subsequent calls.
  static Future<DeviceInfo> getDeviceInfo() async {
    if (_cachedInfo != null) return _cachedInfo!;

    if (Platform.isIOS) {
      final ios = await _deviceInfo.iosInfo;
      _cachedInfo = DeviceInfo(
        deviceId: ios.identifierForVendor ?? 'unknown-ios',
        platform: 'iOS',
        osVersion: ios.systemVersion,
        deviceModel: ios.model,
      );
    } else if (Platform.isAndroid) {
      final android = await _deviceInfo.androidInfo;
      _cachedInfo = DeviceInfo(
        deviceId: android.id,
        platform: 'Android',
        osVersion: android.version.release,
        deviceModel: '${android.manufacturer} ${android.model}',
      );
    } else {
      _cachedInfo = DeviceInfo(
        deviceId: 'unknown',
        platform: 'unknown',
        osVersion: 'unknown',
        deviceModel: 'unknown',
      );
    }

    return _cachedInfo!;
  }

  /// Clears cached device info (useful for testing)
  static void clearCache() {
    _cachedInfo = null;
  }
}
