import 'package:flutter/material.dart';

class EditProfilePicture extends StatelessWidget {
  const EditProfilePicture({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
      ),
    );
  }
}
