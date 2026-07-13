import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class NoResultsUserSearch extends StatelessWidget {
  const NoResultsUserSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: context.colors.border,
                shape: BoxShape.circle,
              ),
              width: 90,
              height: 90,
              child: Icon(
                PhosphorIconsRegular.magnifyingGlass,
                size: 40,
                color: context.colors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No users found',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with a different name.',
              style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
