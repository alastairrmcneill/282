import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/support/contact_support.dart';
import 'package:two_eight_two/widgets/widgets.dart';

enum ReviewSentimentResult { positive, negativeDeclined, negativeFeedbackSent }

/// Asks the user how they're finding the app before requesting an App
/// Store / Play Store review, so the native review prompt (limited to a
/// handful of asks per year on iOS) is only spent on happy users. Unhappy
/// users are offered a direct line to support instead of being asked to
/// leave a public rating.
class ReviewSentimentDialog extends StatefulWidget {
  const ReviewSentimentDialog({super.key});

  @override
  State<ReviewSentimentDialog> createState() => _ReviewSentimentDialogState();
}

class _ReviewSentimentDialogState extends State<ReviewSentimentDialog> {
  bool _showFeedbackStep = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: _showFeedbackStep ? _buildFeedbackStep(context) : _buildSentimentStep(context),
      ),
    );
  }

  Widget _buildSentimentStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(PhosphorIconsRegular.heart, size: 36, color: colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Enjoying 282?',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "We'd love to know how it's going so far.",
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(ReviewSentimentResult.positive),
          child: const Text('Yes, loving it! 🙌'),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          onPressed: () => setState(() => _showFeedbackStep = true),
          child: const Text('Not really'),
        ),
      ],
    );
  }

  Widget _buildFeedbackStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: colorScheme.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(PhosphorIconsRegular.chatCircleText, size: 36, color: colorScheme.primary),
        ),
        const SizedBox(height: 20),
        Text(
          'Sorry to hear that',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "We'd rather hear what's wrong than have you leave a review — mind sending us a quick note?",
          style: textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          onPressed: () async {
            await openSupportEmail(
              context,
              subject: '282 Feedback',
              prefill: "I'm not loving the app right now. Here's why:",
            );
            if (context.mounted) Navigator.of(context).pop(ReviewSentimentResult.negativeFeedbackSent);
          },
          child: const Text('Send feedback'),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          onPressed: () => Navigator.of(context).pop(ReviewSentimentResult.negativeDeclined),
          child: const Text('No thanks'),
        ),
      ],
    );
  }
}
