import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/auth/auth_error_messages.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/legal_urls.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SignUpScreenArgs {
  final bool fromOnboarding;
  const SignUpScreenArgs({this.fromOnboarding = false});
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.fromOnboarding = false});
  static const String route = '${AuthHomeScreen.authRoute}/signup';

  final bool fromOnboarding;

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
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

  void _onFieldChanged() {
    if (mounted) setState(() => _error = null);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final data = RegistrationData()
      ..email = _emailController.text.trim()
      ..password = _passwordController.text.trim()
      ..firstName = _firstNameController.text.trim()
      ..lastName = _lastNameController.text.trim()
      ..displayName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    final authResult = await context.read<AuthState>().registerWithEmail(
          registrationData: data,
          source: widget.fromOnboarding ? 'first_run_onboarding' : null,
        );

    if (!mounted) return;
    if (authResult.success && widget.fromOnboarding) {
      await context.read<MunroCompletionState>().loadUserMunroCompletions();
      if (mounted) {
        Navigator.pushNamed(context, OnboardingNotificationsScreen.route);
      }
    } else if (authResult.success &&
        authResult.showOnboarding &&
        authResult.userId != null) {
      Navigator.pushNamed(
        context,
        InAppOnboardingScreen.route,
        arguments: InAppOnboardingScreenArgs(userId: authResult.userId!),
      );
    } else if (authResult.success) {
      await context.read<MunroCompletionState>().loadUserMunroCompletions();
      Navigator.pushNamedAndRemoveUntil(
          context, HomeScreen.route, (route) => false);
    } else {
      setState(() => _error = mapAuthErrorMessage(authResult.errorMessage));
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.fromOnboarding) ...[
                    const SizedBox(height: 10),
                    const AppleSignInButton(),
                    const SizedBox(height: 10),
                    const GoogleSignInButton(),
                    const SizedBox(height: 20),
                    const TextDivider(text: "or"),
                    const SizedBox(height: 20),
                  ],
                  if (_error != null) ...[
                    AuthErrorBanner(message: _error!),
                    const SizedBox(height: 12),
                  ],
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
                  EmailFormField(
                    textEditingController: _emailController,
                    onChanged: (_) => _onFieldChanged(),
                  ),
                  const SizedBox(height: 12),
                  PasswordFormField(textEditingController: _passwordController),
                  const SizedBox(height: 12),
                  ConfirmPasswordFormField(
                    confirmPassword_TextEditingController:
                        _confirmPasswordController,
                    password_TextEditingController: _passwordController,
                  ),
                  if (password.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    PasswordRequirementsWidget(
                      password: password,
                      confirmPassword: confirmPassword,
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomButtonBar(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CtaButton(
                  onPressed: _submit,
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                const _TermsText(),
              ],
            ),
          ),
        ),
        if (isLoading) BlockingLoadingOverlay(),
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
        text: "By continuing to use 282, you agree to our ",
        style: Theme.of(context).textTheme.bodySmall,
        children: [
          TextSpan(
            text: "Terms & Conditions",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openTermsUrl();
              },
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                openPrivacyPolicyUrl();
              },
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }
}
