import 'package:flutter/material.dart';

class OnboardingStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const OnboardingStepIndicator({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            _StepDot(
              label: steps[i],
              stepNumber: i + 1,
              active: currentStep == i,
              done: currentStep > i,
            ),
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  height: 1,
                  color: currentStep > i ? const Color(0xFF10b981) : Colors.grey[300],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final int stepNumber;
  final bool active;
  final bool done;

  const _StepDot({
    required this.label,
    required this.stepNumber,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? const Color(0xFF10b981) : Colors.grey[300],
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: active ? Colors.white : Colors.grey[600],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? const Color(0xFF10b981) : Colors.grey[500],
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
