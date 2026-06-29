import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/in_app_onboarding/screens/in_app_onboarding_notifications.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/state/onboarding_state.dart';
import 'package:two_eight_two/screens/onboarding/widgets/onboarding_step_indicator.dart';
import 'package:two_eight_two/screens/screens.dart';

class OnboardingNotificationsScreen extends StatefulWidget {
  static const String route = '/onboarding/notifications';
  const OnboardingNotificationsScreen({super.key});

  @override
  State<OnboardingNotificationsScreen> createState() => _OnboardingNotificationsScreenState();
}

class _OnboardingNotificationsScreenState extends State<OnboardingNotificationsScreen> {
  bool _isSaving = false;
  String? _error;

  Future<void> _complete({required bool enableNotifications}) async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final settingsState = context.read<SettingsState>();
      final pushState = context.read<PushNotificationState>();

      if (enableNotifications) {
        await settingsState.setEnablePushNotifications(true);
        final granted = await pushState.enablePush();
        if (!granted) {
          await settingsState.setEnablePushNotifications(false);
        }
      } else {
        await settingsState.setEnablePushNotifications(false);
        await pushState.disablePush();
      }

      final bulkState = context.read<BulkMunroUpdateState>();
      final munroCompletionState = context.read<MunroCompletionState>();
      final achievementsState = context.read<AchievementsState>();
      final appFlagsRepo = context.read<AppFlagsRepository>();
      final userState = context.read<UserState>();

      if (bulkState.addedMunroCompletions.isNotEmpty) {
        await munroCompletionState.addBulkCompletions(
          munroCompletions: bulkState.addedMunroCompletions,
        );
      }

      if (achievementsState.achievementFormCount > 0) {
        await achievementsState.setMunroChallenge();
      }

      await appFlagsRepo.setShowBulkMunroDialog(false);

      final uid = userState.currentUser?.uid;
      if (uid != null) {
        await appFlagsRepo.setShowInAppOnboarding(uid, false);
      }

      if (mounted) {
        await context.read<OnboardingState>().markOnboardingCompleted();
        Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (_) => false);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        icon: Icon(LucideIcons.chevron_left, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                OnboardingStepIndicator(
                  currentStep: 1,
                  steps: const ['Set a goal', 'Notifications'],
                ),
                const Expanded(child: InAppOnboardingNotifications()),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!, style: TextStyle(color: Colors.red[700], fontSize: 14)),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 16, 30, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 54,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF10b981),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          ),
                          onPressed: _isSaving ? null : () => _complete(enableNotifications: true),
                          child: const Text(
                            'Enable Notifications',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: _isSaving ? null : () => _complete(enableNotifications: false),
                          child: Text(
                            'Skip for now',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isSaving)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
