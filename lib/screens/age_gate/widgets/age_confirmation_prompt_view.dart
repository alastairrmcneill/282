import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AgeConfirmationPromptView extends StatelessWidget {
  const AgeConfirmationPromptView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsRegular.identificationCard,
              size: 48,
              color: context.colors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text('Quick age check', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            "282's feed shares photos and posts from other users, so Apple requires us to confirm you're 13 or over before we show it to you. "
            "Tap below and your device will confirm this for us - we don't see or store your age.",
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            onPressed: () => context.read<AgeGateState>().confirmAge(),
            child: const Text('Confirm age'),
          ),
        ],
      ),
    );
  }
}
