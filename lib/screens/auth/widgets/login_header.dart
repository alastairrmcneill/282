import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.green,
          child: Image.asset(
            "assets/icons/app_icon.png",
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Welcome back!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          'Time to get out into the munros!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colors.textSubtitle,
              ),
        ),
      ],
    );
  }
}
