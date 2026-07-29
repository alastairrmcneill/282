package com.example.two_eight_two

import android.os.Build
import android.provider.Settings
import com.google.android.play.agesignals.AgeSignalsManagerFactory
import com.google.android.play.agesignals.AgeSignalsRequest
import com.google.android.play.agesignals.model.AgeSignalsVerificationStatus
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.alastairrmcneill.TwoEightTwo/age_range")
            .setMethodCallHandler { call, result ->
                if (call.method != "requestAgeRange") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                requestAgeSignal(result)
            }

        // Every Play Store upload gets installed and driven through the app by
        // Google's automated review farm as soon as the artifact lands, long
        // before we submit for review. It completes onboarding, so it shows up
        // in analytics as a fake new user. These signals let Flutter recognise
        // that traffic and drop it.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app/environment")
            .setMethodCallHandler { call, result ->
                if (call.method != "environmentInfo") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                result.success(
                    mapOf(
                        "isTestLab" to (Settings.System.getString(contentResolver, "firebase.test.lab") == "true"),
                        "installSource" to installSource(),
                    )
                )
            }
    }

    // Which app put us on this device. Real users always come from the Play
    // Store ("com.android.vending"); anything else is a sideload, an adb push,
    // or Google's review tooling.
    private fun installSource(): String? = try {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            packageManager.getInstallSourceInfo(packageName).installingPackageName
        } else {
            @Suppress("DEPRECATION")
            packageManager.getInstallerPackageName(packageName)
        }
    } catch (e: Exception) {
        null
    }

    // Bridges to Google Play's Age Signals API so Flutter can check a user's
    // age range before unlocking social feed features. Only populated in
    // jurisdictions where Google is legally required to supply it - returns
    // null everywhere else, and Flutter falls back to a self-declared
    // birthdate prompt in that case.
    private fun requestAgeSignal(result: MethodChannel.Result) {
        val ageSignalsManager = AgeSignalsManagerFactory.create(applicationContext)

        ageSignalsManager
            .checkAgeSignals(AgeSignalsRequest.builder().build())
            .addOnSuccessListener { ageSignalsResult ->
                val status = ageSignalsResult.userStatus()
                if (status == null ||
                    status == AgeSignalsVerificationStatus.UNKNOWN ||
                    status == AgeSignalsVerificationStatus.SUPERVISED_APPROVAL_DENIED
                ) {
                    result.success(null)
                } else {
                    result.success(ageSignalsResult.ageLower())
                }
            }
            .addOnFailureListener {
                result.success(null)
            }
    }
}
