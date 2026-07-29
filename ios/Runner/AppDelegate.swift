import UIKit
import Flutter
#if canImport(DeclaredAgeRange)
import DeclaredAgeRange
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let ageRangeChannel = FlutterMethodChannel(
        name: "com.alastairrmcneill.TwoEightTwo/age_range",
        binaryMessenger: controller.binaryMessenger
      )
      ageRangeChannel.setMethodCallHandler { [weak self] call, result in
        guard call.method == "requestAgeRange" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.requestDeclaredAgeRange(result: result)
      }

      // Mirrors the Android channel so Flutter can drop analytics traffic that
      // isn't a real user. App Review and TestFlight builds are signed with a
      // sandbox receipt rather than the production one a store install gets.
      let environmentChannel = FlutterMethodChannel(
        name: "app/environment",
        binaryMessenger: controller.binaryMessenger
      )
      environmentChannel.setMethodCallHandler { call, result in
        guard call.method == "environmentInfo" else {
          result(FlutterMethodNotImplemented)
          return
        }
        let receiptName = Bundle.main.appStoreReceiptURL?.lastPathComponent
        result([
          "isSandboxReceipt": receiptName == "sandboxReceipt",
          "installSource": receiptName as Any,
        ])
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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