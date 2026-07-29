import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/cta_button.dart';

class Onboarding2Screen extends StatefulWidget {
  static const String route = '/onboarding2';
  const Onboarding2Screen({super.key});

  @override
  State<Onboarding2Screen> createState() => _Onboarding2ScreenState();
}

class _Onboarding2ScreenState extends State<Onboarding2Screen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _button1Animation;
  late Animation<double> _button2Animation;
  late Animation<double> _disclaimerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );

    _button1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.75, curve: Curves.easeOut)),
    );

    _button2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.85, curve: Curves.easeOut)),
    );

    _disclaimerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 0.95, curve: Curves.easeOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleYes() {
    context.read<Analytics>().track(
      AnalyticsEvent.munroQuestionAnswered,
      props: {AnalyticsProp.response: 'yes'},
    );
  }

  Future<void> _handleNo() async {
    context.read<Analytics>().track(
      AnalyticsEvent.munroQuestionAnswered,
      props: {AnalyticsProp.response: 'no'},
    );
    await context.read<OnboardingState>().markOnboardingCompleted(branch: 'no');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background photo
          Positioned.fill(
            child: Image.asset(
              'assets/images/welcome_background2.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white,
                height: double.infinity,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIconsBold.warning,
                        color: Colors.black87,
                      ),
                      Text('Please restart the app')
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Lighter teal-tinted overlay — distinct from dark screens
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(84, 1, 23, 17),
                    Color.fromARGB(51, 2, 33, 25),
                    Color.fromARGB(221, 2, 42, 30),
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 24 * (1 - _titleAnimation.value)),
                        child: Opacity(opacity: _titleAnimation.value, child: child),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scotland has 282 Munros.',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.68,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Some of the best scenery in the world!",
                            style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 231, 250, 240), height: 1.55),
                          ),
                          SizedBox(height: 32),
                          Text(
                            'Have you bagged any already?',
                            style: TextStyle(fontSize: 17, color: Color.fromARGB(255, 231, 250, 240), height: 1.55),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: _button1Animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 20 * (1 - _button1Animation.value)),
                        child: Opacity(opacity: _button1Animation.value, child: child),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: CtaButton(
                          onPressed: _handleYes,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.check, size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Yes, I've bagged some!",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: _button2Animation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 20 * (1 - _button2Animation.value)),
                        child: Opacity(opacity: _button2Animation.value, child: child),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: OutlinedButton(
                              onPressed: _handleNo,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                                backgroundColor: Colors.white.withOpacity(0.1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                              ),
                              child: const Text(
                                'No, not yet',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AnimatedBuilder(
                      animation: _disclaimerAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 20 * (1 - _disclaimerAnimation.value)),
                        child: Opacity(opacity: _disclaimerAnimation.value, child: child),
                      ),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "Already got an account? ",
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                          children: [
                            TextSpan(
                              text: "Log in",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                decorationThickness: 1,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context).pushNamed(
                                    LoginScreen.route,
                                    arguments: LoginScreenArgs(fromOnboarding: true),
                                  );
                                },
                            ),
                          ],
                        ),
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
