import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LikeTile extends StatelessWidget {
  final Like like;
  const LikeTile({super.key, required this.like});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircularProfilePicture(
        radius: 15,
        profilePictureURL: like.userProfilePictureURL,
      ),
      title: Text(
        like.userDisplayName,
      ),
      onTap: () {
        ProfileService.loadUserFromUid(context, userId: like.userId);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
      },
    );
  }
}
