import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                        IgnorePointer(
                          child: CircularProfilePicture(
                            radius: 26,
                            profilePictureURL: friend.targetProfilePictureURL,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(
                            friend.targetDisplayName ?? '',
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
