import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SelectedFriendsScroll extends StatelessWidget {
  const SelectedFriendsScroll({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GroupFilterState>();
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: state.selectedFriends.isEmpty
          ? const SizedBox.shrink()
          : SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                itemCount: state.selectedFriends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final friend = state.selectedFriends[index];
                  return GestureDetector(
                    onTap: () => context.read<GroupFilterState>().removeSelectedFriend(uid: friend.targetId),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            IgnorePointer(
                              child: CircularProfilePicture(
                                radius: 26,
                                profilePictureURL: friend.targetProfilePictureURL,
                              ),
                            ),
                            Positioned(
                              top: -2,
                              right: -2,
                              child: _RemoveBadge(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(
                            friend.targetFirstName,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RemoveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.textMuted,
        border: Border.all(color: context.colors.surface, width: 1.5),
      ),
      child: Icon(
        PhosphorIconsRegular.x,
        color: Colors.white,
        size: 11,
      ),
    );
  }
}
