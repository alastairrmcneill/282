// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/screens.dart';

class RegistrationPasswordScreenArgs {
  final RegistrationData registrationData;

  RegistrationPasswordScreenArgs({required this.registrationData});
}

class RegistrationPasswordScreen extends StatelessWidget {
  final RegistrationPasswordScreenArgs args;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegistrationPasswordScreen({super.key, required this.args});
  static const String route = '${AuthHomeScreen.authRoute}/registration/password';

  @override
  Widget build(BuildContext context) {
    RegistrationData registrationData = args.registrationData;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 2 of 3"),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Passwords",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                PasswordFormField(textEditingController: _passwordController),
                const SizedBox(height: 15),
                ConfirmPasswordFormField(
                  confirmPassword_TextEditingController: _confirmPasswordController,
                  password_TextEditingController: _passwordController,
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "\u2022 At least one uppercase letter.\n\u2022 At least one lowercase letter.\n\u2022 At least one digit.\n\u2022 At least one special character.\n\u2022 Must be 8 characters or more.",
                    ),
                  ),
                ),
                Expanded(flex: 1, child: Container()),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      _formKey.currentState!.save();

                      registrationData.password = _passwordController.text.trim();
                      Navigator.of(context).pushNamed(
                        RegistrationNamesScreen.route,
                        arguments: RegistrationNamesScreenArgs(
                          registrationData: registrationData,
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
