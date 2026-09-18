import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AuthHomeScreenArgs {
  final String? gateSource;
  const AuthHomeScreenArgs({this.gateSource});
}

class AuthHomeScreen extends StatefulWidget {
  final String? gateSource;
  const AuthHomeScreen({super.key, this.gateSource});
  static const String authRoute = '/auth';
  static const String route = '$authRoute/home';

  @override
  State<AuthHomeScreen> createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthState>().status == AuthStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/images/login_background1.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                context.read<Analytics>().track(AnalyticsEvent.authHomeCloseButtonTapped);
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                CupertinoIcons.xmark,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Discover\nScotland's Munros",
                        style: TextStyle(
                          fontFamily: "NotoSans",
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ), // Not centered
                    ),
                    const SizedBox(height: 30),
                    AppleSignInButton(style: SignInWithAppleButtonStyle.white, gateSource: widget.gateSource),
                    const SizedBox(height: 20),
                    GoogleSignInButton(gateSource: widget.gateSource),
                    const SizedBox(height: 15),
                    const TextDivider(text: "or", color: Colors.white),
                    const SizedBox(height: 15),
                    CreateFreeAccountButton(gateSource: widget.gateSource),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Already have an account? ",
                        children: [
                          TextSpan(
                            text: "Log in",
                            style: const TextStyle(
                              fontFamily: "NotoSans",
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushNamed(
                                  LoginScreen.route,
                                  arguments: LoginScreenArgs(gateSource: widget.gateSource),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const ConsentText(
                      initialText: "By continuing to use 282, you agree to our ",
                      termsText: "Terms",
                      privacyPolicyText: "Privacy Policy",
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isLoading) BlockingLoadingOverlay(),
        ],
      ),
    );
  }
}
