import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';

class CreateFreeAccountButton extends StatelessWidget {
  const CreateFreeAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed(RegistrationEmailScreen.route);
        },
        child: const Text('Create a free account'),
      ),
    );
  }
}
