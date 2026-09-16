import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class OnboardingWelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;

  const OnboardingWelcomeScreen({super.key, required this.onNext});

  @override
  State<OnboardingWelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<OnboardingWelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = context.read<OnboardingState>();

    Widget buildStatItem(String stat, String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stat,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.colors.accent,
              height: 0,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 0,
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1546706872-9c90b8d0c94f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzY290dGlzaCUyMGhpZ2hsYW5kJTIwbW91bnRhaW4lMjBwZWFrfGVufDF8fHx8MTc3MDIwMzAzNnww&ixlib=rb-4.1.0&q=80&w=1080',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
              );
            },
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Content
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: RepaintBoundary(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Title
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                          child: Opacity(
                            opacity: _titleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'Scratch off\nScotland.',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle
                    AnimatedBuilder(
                      animation: _subtitleAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - _subtitleAnimation.value)),
                          child: Opacity(
                            opacity: _subtitleAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: const Text(
                        'Every Munro you climb is an experience. Scratch them off your own map!',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFe2e8f0),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Stats row
                    AnimatedBuilder(
                        animation: _subtitleAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 30 * (1 - _subtitleAnimation.value)),
                            child: Opacity(
                              opacity: _subtitleAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Divider(
                              color: AppColors.light.divider.withOpacity(0.5),
                              thickness: 0.8,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                buildStatItem('282', 'Munros'),
                                const SizedBox(width: 24),
                                buildStatItem((onboardingState.totals?.totalMunroCompletions ?? 0).shortenedThousands(),
                                    'summits logged'),
                                const SizedBox(width: 24),
                                buildStatItem(
                                    (onboardingState.totals?.totalUsers ?? 0).shortenedThousands(), 'baggers'),
                              ],
                            ),
                            SizedBox(height: 16),
                            Divider(
                              color: AppColors.light.divider.withOpacity(0.5),
                              thickness: 0.8,
                            ),
                          ],
                        )),
                    const SizedBox(height: 32),
                    // Button
                    AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - _buttonAnimation.value)),
                          child: Opacity(
                            opacity: _buttonAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: CtaButton(
                        onPressed: widget.onNext,
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(PhosphorIconsBold.caretRight),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Footer text
                    Align(
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          );
                        },
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "I already have an account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.dark.textSubtitle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
