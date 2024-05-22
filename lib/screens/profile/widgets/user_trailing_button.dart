import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';

class UserTrailingButton extends StatefulWidget {
  final String profileUserId;
  final String profileUserDisplayName;
  final String profileUserPictureURL;
  const UserTrailingButton({
    super.key,
    required this.profileUserId,
    required this.profileUserDisplayName,
    required this.profileUserPictureURL,
  });

  @override
  State<UserTrailingButton> createState() => _UserTrailingButtonState();
}

class _UserTrailingButtonState extends State<UserTrailingButton> {
  bool following = true;
  bool isCurrentUser = true;

  @override
  void initState() {
    super.initState();
    loadData(context);
  }

  Future loadData(BuildContext context) async {
    AppUser user = Provider.of<AppUser>(context, listen: false);
    following = await ProfileService.isFollowingUser(
      context,
      currentUserId: user.uid!,
      profileUserId: widget.profileUserId,
    );

    isCurrentUser = user.uid == widget.profileUserId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return following || isCurrentUser
        ? const SizedBox()
        : ElevatedButton(
            onPressed: () async {
              FollowingService.followUser(
                context,
                profileUserId: widget.profileUserId,
                profileUserDisplayName: widget.profileUserDisplayName,
                profileUserPictureURL: widget.profileUserPictureURL,
              );
              setState(() {
                following = true;
              });
            },
            child: const Text("Follow"),
          );
  }
}
