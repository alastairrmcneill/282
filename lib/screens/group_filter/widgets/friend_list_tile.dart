import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FriendListTile extends StatelessWidget {
  final FollowingRelationship friend;
  final bool isSelected;
  final VoidCallback onTap;

  const FriendListTile({
    super.key,
    required this.friend,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.accent.withValues(alpha: 0.08)
              : context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.colors.accent.withValues(alpha: 0.4)
                : context.colors.border,
            width: isSelected ? 1.5 : 0.65,
          ),
        ),
        child: Row(
          children: [
            CircularProfilePicture(
              radius: 24,
              profilePictureURL: friend.targetProfilePictureURL,
              profileUid: friend.targetId,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                friend.targetFirstName,
                style: theme.textTheme.titleMedium,
              ),
            ),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;
  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? context.colors.accent : Colors.transparent,
        border: Border.all(
          color: isSelected ? context.colors.accent : context.colors.border,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(PhosphorIconsRegular.check, color: Colors.white, size: 14)
          : null,
    );
  }
}
