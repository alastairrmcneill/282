import UIKit
import Flutter
import FirebaseMessaging
#if canImport(DeclaredAgeRange)
import DeclaredAgeRange
#endif

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register plugins on FlutterAppDelegate's lazy launch engine now, before returning.
    // Some plugins (e.g. firebase_messaging's cold-start push handling) attach an
    // NSNotificationCenter observer for UIApplicationDidFinishLaunchingNotification during
    // registration - a one-shot broadcast fired the instant this method returns. Registering
    // later, in didInitializeImplicitFlutterEngine (only once the storyboard's
    // FlutterViewController is created), misses that notification permanently.
    // FlutterViewController picks up this same engine later via takeLaunchEngine.
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // FirebaseAppDelegateProxyEnabled is false, so nothing swizzles this token onto Messaging
  // automatically - forward it explicitly rather than relying on FCM's own delegate proxy.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Plugins are already registered from didFinishLaunchingWithOptions (same engine, handed off
  // via takeLaunchEngine) - only app-specific channel setup happens here.
  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    let ageRangeChannel = FlutterMethodChannel(
      name: "com.alastairrmcneill.TwoEightTwo/age_range",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    ageRangeChannel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "requestAgeRange" else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.requestDeclaredAgeRange(result: result)
    }
  }

  // Bridges to Apple's Declared Age Range API (iOS 26+) so Flutter can check
  // a user's age range before unlocking social feed features. Returns the
  // lower bound of the declared range via `result`, or nil if the API is
  // unavailable, the user declined to share, or the call failed - Flutter
  // falls back to a self-declared birthdate prompt in that case.
  private func requestDeclaredAgeRange(result: @escaping FlutterResult) {
    #if canImport(DeclaredAgeRange)
    if #available(iOS 26.0, *) {
      guard let rootViewController = window?.rootViewController else {
        result(nil)
        return
      }
      Task {
        do {
          // TODO: verify the response enum case against the DeclaredAgeRange
          // framework (Xcode 26 autocomplete / Apple docs) before release -
          // the signature below is now compiler-verified, but `.sharing` is
          // still a guess at the actual case name.
          let response = try await AgeRangeService.shared.requestAgeRange(ageGates: 13, in: rootViewController)
          switch response {
          case .sharing(let range):
            result(range.lowerBound)
          default:
            result(nil)
          }
        } catch {
          result(nil)
        }
      }
      return
    }
    #endif
    result(nil)
  }
}