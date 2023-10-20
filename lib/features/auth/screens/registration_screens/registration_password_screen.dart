import 'package:flutter/material.dart';
import 'package:two_eight_two/features/auth/screens/screens.dart';
import 'package:two_eight_two/features/auth/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';

class RegistrationPasswordScreen extends StatelessWidget {
  final RegistrationData registrationData;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegistrationPasswordScreen({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 2 of 3"),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Passwords",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RegistrationNamesScreen(
                            registrationData: registrationData,
                          ),
                        ),
                      );
                    },
                    child: Text('Next'),
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
