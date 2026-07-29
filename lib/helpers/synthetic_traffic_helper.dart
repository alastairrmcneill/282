import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:two_eight_two/config/app_config.dart';

/// The outcome of classifying a session, plus the raw signals it was based on.
///
/// The signals are registered as Mixpanel super properties so that anything
/// which slips past [isSynthetic] can still be identified after the fact - if
/// a crawler shows up in the funnel again we can read its fingerprint straight
/// off the event rather than guessing at another release.
class TrafficClassification {
  final bool isSynthetic;
  final Map<String, dynamic> signals;

  const TrafficClassification({required this.isSynthetic, required this.signals});
}

/// Detects analytics sessions that don't come from a real user.
///
/// The one that actually pollutes the funnel is Google's store review farm.
/// Every Play Store upload is installed and driven through the app by an
/// automated crawler - a OnePlus 8 Pro on Android 11, US IP, cellular only -
/// the moment the release pipeline finishes, well before the build is ever
/// submitted for review. It taps through onboarding, so it lands in Mixpanel
/// as a fake new user. It has hit every release we've shipped.
///
/// That farm is not Firebase Test Lab, so the Test Lab system setting doesn't
/// see it. What it can't fake is the install source: a real user's copy is put
/// there by the Play Store app, and nothing else is.
class SyntheticTrafficHelper {
  static const _channel = MethodChannel('app/environment');
  static const _playStorePackage = 'com.android.vending';

  static Future<TrafficClassification> classify({required AppEnvironment env}) async {
    final isPhysicalDevice = await _isPhysicalDevice();
    final environment = await _environmentInfo();

    final installSource = environment['installSource'] as String?;
    final isTestLab = environment['isTestLab'] == true;
    final isSandboxReceipt = environment['isSandboxReceipt'] == true;

    final signals = <String, dynamic>{
      'install_source': installSource ?? 'unknown',
      'is_physical_device': isPhysicalDevice,
      if (Platform.isAndroid) 'is_test_lab': isTestLab,
      if (Platform.isIOS) 'is_sandbox_receipt': isSandboxReceipt,
    };

    return TrafficClassification(
      isSynthetic: _isSynthetic(
        env: env,
        isPhysicalDevice: isPhysicalDevice,
        isTestLab: isTestLab,
        isSandboxReceipt: isSandboxReceipt,
        installSource: installSource,
      ),
      signals: signals,
    );
  }

  static bool _isSynthetic({
    required AppEnvironment env,
    required bool isPhysicalDevice,
    required bool isTestLab,
    required bool isSandboxReceipt,
    required String? installSource,
  }) {
    // Dev builds are sideloaded onto simulators by definition, so every dev
    // session would look synthetic. Dev traffic belongs in the dev Mixpanel
    // project regardless.
    if (env != AppEnvironment.prod) return false;

    if (!isPhysicalDevice) return true;

    if (Platform.isAndroid) {
      if (isTestLab) return true;
      // Anything that didn't arrive via the Play Store is a sideload, an adb
      // push, or Google's review tooling - never a real user, since Play is
      // the only channel we publish to.
      return installSource != _playStorePackage;
    }

    if (Platform.isIOS) {
      // Deliberately narrower than Android: a missing receipt is ambiguous on
      // iOS, and silently dropping real users costs more than letting the odd
      // review session through. `install_source` is on every event if we need
      // to tighten this later.
      return isSandboxReceipt;
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

  static Future<Map<Object?, Object?>> _environmentInfo() async {
    try {
      return await _channel.invokeMethod<Map<Object?, Object?>>('environmentInfo') ?? {};
    } catch (_) {
      return {};
    }
  }
}
