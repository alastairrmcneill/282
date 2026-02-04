import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class OnboardingPrimaryButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const OnboardingPrimaryButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<OnboardingPrimaryButton> createState() => _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<OnboardingPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10b981), Color(0xFF14b8a6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10b981).withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}

class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OnboardingBackButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            LucideIcons.chevron_left,
            color: Colors.white,
            size: 20,
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

  const OnboardingNavigationButtons({
    super.key,
    required this.onNext,
    this.onBack,
    this.nextText = 'Continue',
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          if (onBack != null) ...[
            OnboardingBackButton(onPressed: onBack!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: OnboardingPrimaryButton(
              onPressed: onNext,
              text: nextText,
            ),
          ),
        ],
      ),
    );
  }
}
