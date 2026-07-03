import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class GroupFilterBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onClear;
  final VoidCallback? onConfirm;

  const GroupFilterBottomBar({
    super.key,
    required this.selectedCount,
    required this.onClear,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(color: context.colors.border, width: 0.65),
        ),
      ),
      child: BottomButtonBar(
        child: Row(
          children: [
            TextButton(
              onPressed: onClear,
              child: const Text("Clear"),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                onPressed: onConfirm,
                child: Text(
                  "View Munros ($selectedCount ${selectedCount == 1 ? 'friend' : 'friends'})",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
