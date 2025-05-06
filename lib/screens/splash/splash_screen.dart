import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 140,
          height: 140,
          child: Image.asset(
            'assets/icons/app_icon_transparent.png',
          ),
        ),
      ),
    );
  }
}
