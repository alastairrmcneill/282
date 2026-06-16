import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String route = '${AuthHomeScreen.authRoute}/signup';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final data = RegistrationData()
      ..email = _emailController.text.trim()
      ..password = _passwordController.text.trim()
      ..firstName = _firstNameController.text.trim()
      ..lastName = _lastNameController.text.trim()
      ..displayName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    final authResult = await context.read<AuthState>().registerWithEmail(registrationData: data);

    if (!mounted) return;
    if (authResult.success && authResult.showOnboarding && authResult.userId != null) {
      Navigator.pushNamed(
        context,
        InAppOnboardingScreen.route,
        arguments: InAppOnboardingScreenArgs(userId: authResult.userId!),
      );
    } else if (authResult.success) {
      Navigator.pushNamedAndRemoveUntil(context, HomeScreen.route, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().status == AuthStatus.loading;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Create Account')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AppleSignInButton(style: SignInWithAppleButtonStyle.black),
                  const SizedBox(height: 10),
                  const GoogleSignInButton(),
                  const SizedBox(height: 20),
                  const _OrDivider(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: NameFormField(
                          textEditingController: _firstNameController,
                          hintText: 'First Name',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NameFormField(
                          textEditingController: _lastNameController,
                          hintText: 'Last Name',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  EmailFormField(textEditingController: _emailController),
                  const SizedBox(height: 12),
                  PasswordFormField(textEditingController: _passwordController),
                  const SizedBox(height: 12),
                  ConfirmPasswordFormField(
                    confirmPassword_TextEditingController: _confirmPasswordController,
                    password_TextEditingController: _passwordController,
                  ),
                  if (password.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    PasswordRequirementsWidget(
                      password: password,
                      confirmPassword: confirmPassword,
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _TermsText(),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.colors.textSubtitle,
                ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'By continuing to use 282, you agree to our ',
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: 'Terms & Conditions',
            style: TextStyle(
              color: context.colors.accent,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => showDocumentDialog(
                    context,
                    mdFileName: 'assets/documents/terms_and_conditions.md',
                  ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: context.colors.accent,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => showDocumentDialog(
                    context,
                    mdFileName: 'assets/documents/privacy_policy.md',
                  ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}
