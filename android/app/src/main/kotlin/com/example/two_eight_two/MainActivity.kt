package com.example.two_eight_two

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
