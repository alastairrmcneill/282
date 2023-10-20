import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          child: Text('282'),
          // child: Image.asset(
          //   "assets/icons/logo.png",
          // ),
        ),
        SizedBox(height: 10),
        Text(
          'Welcome back!',
          style: TextStyle(
            fontFamily: "NotoSans",
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          'Time to get out into the munros!',
          style: TextStyle(
            fontFamily: "NotoSans",
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
