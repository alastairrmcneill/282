import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CirculeProfilePicture extends StatelessWidget {
  final String? profilePictureURL;
  final int radius;

  const CirculeProfilePicture({
    super.key,
    this.profilePictureURL,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[350],
        image: profilePictureURL == null
            ? null
            : DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  profilePictureURL!,
                ),
              ),
      ),
      child: profilePictureURL == null
          ? ClipOval(
              child: Icon(
                Icons.person_rounded,
                color: Colors.grey[600],
                size: radius * 1.4,
              ),
            )
          : null,
    );
  }
}
