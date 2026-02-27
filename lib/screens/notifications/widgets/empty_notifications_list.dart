import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/support/theme.dart';

class EmptyNotificationsList extends StatelessWidget {
  const EmptyNotificationsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: MyColors.lightGrey,
                shape: BoxShape.circle,
              ),
              width: 60,
              height: 60,
              child: Icon(
                PhosphorIconsRegular.checks,
                size: 30,
                color: MyColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            Text('You\'re all caught up!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(
              'No new notifications right now. Keep bagging those munros and check back soon!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
