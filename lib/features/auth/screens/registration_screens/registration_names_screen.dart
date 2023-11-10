import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/features/auth/widgets/widgets.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/services/auth_service.dart';

class RegistrationNamesScreen extends StatelessWidget {
  final RegistrationData registrationData;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegistrationNamesScreen({super.key, required this.registrationData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 3 of 3"),
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
                  "What is your name?",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
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
                    style: TextStyle(
                        fontFamily: "NotoSans", fontWeight: FontWeight.w400, color: Colors.grey[500], fontSize: 12),
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
                      await AuthService.registerWithEmail(
                        context,
                        registrationData: registrationData,
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
