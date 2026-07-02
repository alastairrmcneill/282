import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/auth/auth_error_messages.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LoginScreenArgs {
  final bool fromOnboarding;
  const LoginScreenArgs({this.fromOnboarding = false});
}

class LoginScreen extends StatefulWidget {
  static const String route = '${AuthHomeScreen.authRoute}/login';
  const LoginScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_clearError);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null && mounted) setState(() => _error = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final result = await context.read<AuthState>().signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

    if (!mounted) return;

    if (result.success && widget.fromOnboarding) {
      await context.read<MunroCompletionState>().loadUserMunroCompletions();
      if (mounted) {
        Navigator.pushNamed(context, OnboardingNotificationsScreen.route);
      }
    } else if (result.success && result.showOnboarding && result.userId != null) {
      Navigator.pushNamed(
        context,
        InAppOnboardingScreen.route,
        arguments: InAppOnboardingScreenArgs(userId: result.userId!),
      );
    } else if (result.success) {
      await context.read<MunroCompletionState>().loadUserMunroCompletions();
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
    } else {
      setState(() => _error = mapAuthErrorMessage(result.errorMessage));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().status == AuthStatus.loading;
    return Stack(
      children: [
        Scaffold(
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
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(2),
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(CupertinoIcons.xmark, size: 18),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_error != null) ...[
                          AuthErrorBanner(message: _error!),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 10),
                        EmailFormField(
                          textEditingController: _emailController,
                          onChanged: (_) => _clearError(),
                        ),
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
                        CtaButton(
                          onPressed: _submit,
                          child: const Text('Log in'),
                        ),
                        const ForgotPasswordButton(),
                        if (!widget.fromOnboarding) ...[
                          const SizedBox(height: 20),
                          AppleSignInButton(onError: (msg) => setState(() => _error = msg)),
                          const SizedBox(height: 10),
                          GoogleSignInButton(onError: (msg) => setState(() => _error = msg)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading) BlockingLoadingOverlay(),
      ],
    );
  }
}
