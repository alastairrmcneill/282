import 'package:sentry_flutter/sentry_flutter.dart';

/// Android's ANRv2 (AppExitInfo) detector frequently reports the main thread
/// as "not responding" while the app is backgrounded and simply idling in
/// the OS message loop (Looper/MessageQueue, Zygote, JNI, syscall frames) —
/// there's no first-party code involved and nothing for us to act on.
/// Sentry's own docs note these system-frame-only background ANRs are mostly
/// noise, so we drop them rather than let them pile up as unresolved
/// production issues.
bool isNoisyBackgroundAnr(SentryEvent event) {
  final exceptions = event.exceptions;
  if (exceptions == null) return false;

  final isAppExitInfoAnr = exceptions.any((exception) => exception.mechanism?.type == 'AppExitInfo');
  if (!isAppExitInfoAnr) return false;

  if (event.contexts.app?.inForeground != false) return false;

  final hasFirstPartyFrame = exceptions
      .expand((exception) => exception.stackTrace?.frames ?? const [])
      .any((frame) => frame.inApp == true);

  return !hasFirstPartyFrame;
}
