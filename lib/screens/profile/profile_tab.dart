// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileScreen(),
    );
  }
}
