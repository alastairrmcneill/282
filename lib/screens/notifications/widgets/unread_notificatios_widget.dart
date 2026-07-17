import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class UnreadNotificatiosWidget extends StatelessWidget {
  final int count;
  const UnreadNotificatiosWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      color: context.colors.divider,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        '$count unread notification${count == 1 ? '' : 's'}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textPrimary),
      ),
    );
  }
}
