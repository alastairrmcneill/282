import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class BirthdatePromptView extends StatefulWidget {
  const BirthdatePromptView({super.key});

  @override
  State<BirthdatePromptView> createState() => _BirthdatePromptViewState();
}

class _BirthdatePromptViewState extends State<BirthdatePromptView> {
  DateTime? _birthdate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateController = TextEditingController(
      text: _birthdate != null ? DateFormat('dd/MM/yyyy').format(_birthdate!) : null,
    );

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
              PhosphorIconsRegular.cake,
              size: 48,
              color: context.colors.accent,
            ),
          ),
          const SizedBox(height: 20),
          Text('Confirm your date of birth', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            "282's feed shares photos and posts from other users, so the law requires us to confirm you're old enough before we show it to you. "
            "We couldn't verify this automatically on your device, so please pop in your date of birth - we only use it for this check.",
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AppTextFormField(
            controller: dateController,
            prefixIcon: Icon(
              PhosphorIconsRegular.calendarBlank,
              size: 22,
              color: context.colors.textMuted,
            ),
            readOnly: true,
            hintText: 'DD/MM/YYYY',
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                helpText: 'Date of Birth',
                initialDate: now,
                firstDate: DateTime(now.year - 120),
                lastDate: now,
              );

              if (picked != null) {
                setState(() => _birthdate = picked);
              }
            },
            validator: (value) => null,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: _birthdate == null
                ? null
                : () => context.read<AgeGateState>().submitBirthdate(_birthdate!),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
