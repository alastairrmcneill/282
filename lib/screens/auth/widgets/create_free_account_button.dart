import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateFreeAccountButton extends StatelessWidget {
  final String? gateSource;
  const CreateFreeAccountButton({super.key, this.gateSource});

  @override
  Widget build(BuildContext context) {
    return CtaButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          SignUpScreen.route,
          arguments: SignUpScreenArgs(gateSource: gateSource),
        );
      },
      child: const Text('Create a free account'),
    );
  }
}
