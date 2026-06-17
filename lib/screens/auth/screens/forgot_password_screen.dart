import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static const String route = '${AuthHomeScreen.authRoute}/forgot_password';
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSuccess = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _error = null);

    final result = await context.read<AuthState>().forgotPassword(
          email: _emailController.text.trim(),
        );

    if (result.success) {
      setState(() => _isSuccess = true);
    } else {
      setState(() => _error = result.errorMessage ?? 'Failed to send reset email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().status == AuthStatus.loading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Recovery'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _isSuccess
              ? ForgotPasswordSuccessView(
                  email: _emailController.text,
                  onBackToLogin: () => Navigator.of(context).pop(),
                  onTryAgain: () => setState(() {
                    _isSuccess = false;
                    _error = null;
                  }),
                )
              : ForgotPasswordFormView(
                  formKey: _formKey,
                  emailController: _emailController,
                  onSubmit: _submit,
                  error: _error,
                  isLoading: isLoading,
                ),
        ),
      ),
    );
  }
}
