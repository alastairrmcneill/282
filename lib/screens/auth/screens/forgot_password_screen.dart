import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ForgotPasswordScreen({super.key});
  static const String route = '${AuthHomeScreen.authRoute}/forgot_password';

  Future _forgotPassword(BuildContext context) async {
    await AuthService.forgotPassword(context, email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Text(
                  'To reset your password, please enter your email address below.',
                  textAlign: TextAlign.center,
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    EmailFormField(textEditingController: _emailController),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    _formKey.currentState!.save();

                    await _forgotPassword(context);
                  },
                  child: const Text('Send email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
