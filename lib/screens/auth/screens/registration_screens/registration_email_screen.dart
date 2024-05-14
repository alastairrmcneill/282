// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/models/models.dart';

class RegistrationEmailScreen extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  RegistrationEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Step 1 of 3"),
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
                  "What is your email?",
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 20),
                EmailFormField(textEditingController: _emailController),
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
                      RegistrationData registrationData = RegistrationData();
                      registrationData.email = _emailController.text.trim();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RegistrationPasswordScreen(
                            registrationData: registrationData,
                          ),
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
