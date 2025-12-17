// ignore_for_file: must_be_immutable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class RegistrationNamesScreenArgs {
  final RegistrationData registrationData;

  RegistrationNamesScreenArgs({required this.registrationData});
}

class RegistrationNamesScreen extends StatelessWidget {
  final RegistrationNamesScreenArgs args;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegistrationNamesScreen({super.key, required this.args});
  static const String route = '${AuthHomeScreen.authRoute}/registration/names';

  @override
  Widget build(BuildContext context) {
    RegistrationData registrationData = args.registrationData;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 3 of 3"),
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
                  "What is your name?",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                NameFormField(
                  textEditingController: _firstNameController,
                  hintText: "First Name",
                ),
                const SizedBox(height: 15),
                NameFormField(
                  textEditingController: _lastNameController,
                  hintText: "Last Name",
                ),
                const SizedBox(height: 15),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "By continuing to use 282, you agree to our ",
                    style: Theme.of(context).textTheme.bodySmall,
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: const TextStyle(
                          fontFamily: "NotoSans",
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDocumentDialog(context, mdFileName: 'assets/documents/terms_and_conditions.md');
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: const TextStyle(
                          fontFamily: "NotoSans",
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            showDocumentDialog(context, mdFileName: 'assets/documents/privacy_policy.md');
                          },
                      ),
                      const TextSpan(text: "."),
                    ],
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

                      registrationData.displayName =
                          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";
                      registrationData.firstName = _firstNameController.text.trim();
                      registrationData.lastName = _lastNameController.text.trim();
                      final authResult = await context.read<AuthState>().registerWithEmail(
                            registrationData: registrationData,
                          );

                      if (authResult.success && authResult.showOnboarding) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          InAppOnboarding.route,
                          (route) => false,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          HomeScreen.route,
                          (route) => false,
                        );
                      }
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
