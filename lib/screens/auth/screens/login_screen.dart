// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';

class LoginScreen extends StatelessWidget {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  Future _submit(BuildContext context) async {
    await AuthService.signInWithEmail(
      context,
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 0.3, color: Colors.black54),
                          color: Colors.white,
                          shape: BoxShape.circle),
                      child: IconButton(
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(2),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const LoginHeader(),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    EmailFormField(textEditingController: _emailController),
                    const SizedBox(height: 15),
                    PasswordFormField(
                      textEditingController: _passwordController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }
                          _formKey.currentState!.save();
                          await _submit(context);
                        },
                        child: const Text('Log in'),
                      ),
                    ),
                    const ForgotPasswordButton(),
                    const SizedBox(height: 20),
                    const AppleSignInButton(style: SignInWithAppleButtonStyle.black),
                    const SizedBox(height: 10),
                    const GoogleSignInButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
