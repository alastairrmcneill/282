import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateFreeAccountButton extends StatelessWidget {
  const CreateFreeAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CtaButton(
      onPressed: () {
        Navigator.of(context).pushNamed(SignUpScreen.route);
      },
      child: const Text('Create a free account'),
    );
  }
}
