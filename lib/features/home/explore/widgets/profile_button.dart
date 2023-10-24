import 'package:flutter/material.dart';
import 'package:two_eight_two/general/services/services.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await AuthService.signOut(context);
      },
      icon: Icon(Icons.person),
    );
  }
}
