import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/services/services.dart';

import '../screens/profile/screens/screens.dart';

class CircularProfilePicture extends StatelessWidget {
  final String? profileUid;
  final String? profilePictureURL;
  final int radius;

  const CircularProfilePicture({
    super.key,
    this.profileUid,
    this.profilePictureURL,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (profileUid == null) return;
        ProfileService.loadUserFromUid(context, userId: profileUid!);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
      },
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[350],
          image: profilePictureURL == null || profilePictureURL == ''
              ? null
              : DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                    profilePictureURL!,
                  ),
                ),
        ),
        child: profilePictureURL == null || profilePictureURL == ''
            ? ClipOval(
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.grey[600],
                  size: radius * 1.4,
                ),
              )
            : null,
      ),
    );
  }
}
