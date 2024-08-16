import 'package:flutter/material.dart';

class InAppOnboardingWelcome extends StatelessWidget {
  const InAppOnboardingWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, right: 30, left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/welcome_screen_image1.png',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'It is time to\nbecome an explorer!  🏔️',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Discover all the munros in Scotland and track your progress, link up with friends and make memories that will last a lifetime!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}
