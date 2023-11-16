import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/screens/auth/screens/screens.dart';

class AuthHomeScreen extends StatefulWidget {
  const AuthHomeScreen({super.key});

  @override
  State<AuthHomeScreen> createState() => _AuthHomeScreenState();
}

class _AuthHomeScreenState extends State<AuthHomeScreen> {
  @override
  Widget build(BuildContext context) {
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
                    const AppleSignInButton(),
                    const SizedBox(height: 10),
                    const GoogleSignInButton(),
                    const SizedBox(height: 10),
                    const TextDivider(text: "or"),
                    const SizedBox(height: 10),
                    const CreateFreeAccountButton(),
                    const SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: "Already have an account? ",
                        style: const TextStyle(fontFamily: "NotoSans"),
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
