import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

/// Detects analytics sessions that don't come from a real user: Android's
/// automated Firebase Test Lab pre-launch report (fires on every Play Store
/// upload, before review, via the Robo crawler) and local emulators/simulators.
class SyntheticTrafficHelper {
  static const _channel = MethodChannel('app/environment');

  static Future<bool> isSyntheticTraffic() async {
    if (!await _isPhysicalDevice()) return true;

    if (Platform.isAndroid) {
      try {
        return await _channel.invokeMethod<bool>('isTestLab') ?? false;
      } catch (_) {
        return false;
      }
    }

    return false;
  }

  static Future<bool> _isPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      return (await deviceInfo.androidInfo).isPhysicalDevice;
    } else if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).isPhysicalDevice;
    }
    return true;
  }
}
