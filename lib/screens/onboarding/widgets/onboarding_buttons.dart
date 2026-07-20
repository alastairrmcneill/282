import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class OnboardingPrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double height;

  const OnboardingPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.height = 50,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(68, 186, 130, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.chevron_right,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  /// Forces light (true) or dark (false) icon/border, overriding the app
  /// theme. Use this for screens with a fixed photo background where the
  /// button must stay readable regardless of light/dark mode. Leave null to
  /// follow the current theme brightness.
  final bool? backButtonLight;

  const OnboardingBackButton({
    super.key,
    required this.onPressed,
    this.backButtonLight,
  });

  @override
  Widget build(BuildContext context) {
    final light = backButtonLight ?? Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 70,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: OutlinedButton(
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.transparent,
              side: BorderSide(
                  color: light ? Colors.white.withAlpha(100) : Colors.black.withAlpha(100),
                  width: 0.5), // Border color and width
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Center(
              child: Icon(
                LucideIcons.chevron_left,
                color: light ? Colors.white.withAlpha(200) : Colors.black.withAlpha(200),
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextText;
  final bool isLastPage;
  final double height;
  final bool? backButtonLight;

  const OnboardingNavigationButtons({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextText = 'Continue',
    this.isLastPage = false,
    this.height = 50,
    this.backButtonLight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null) ...[
          OnboardingBackButton(onPressed: onBack!, backButtonLight: backButtonLight),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OnboardingPrimaryButton(
            onPressed: onNext,
            text: nextText,
            height: height,
          ),
        ),
      ],
    );
  }
}
