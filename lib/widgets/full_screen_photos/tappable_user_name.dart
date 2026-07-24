import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/screens.dart';

class TappableUserName extends StatelessWidget {
  final String userId;
  final String userName;
  const TappableUserName({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          ProfileScreen.route,
          arguments: ProfileScreenArgs(userId: userId),
        );
      },
      child: Text(
        userName,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
