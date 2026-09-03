import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaScanningPulse extends StatefulWidget {
  const StravaScanningPulse({super.key});

  @override
  State<StravaScanningPulse> createState() => _StravaScanningPulseState();
}

class _StravaScanningPulseState extends State<StravaScanningPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _ringPhases = [0.0, 0.33, 0.66];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              for (final phase in _ringPhases) _buildRing(context, phase),
              child!,
            ],
          );
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.accent,
          ),
          child: const Icon(PhosphorIconsBold.personSimpleHike, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // Rings loop endlessly, each offset by a phase so they pulse outwards in sequence.
  Widget _buildRing(BuildContext context, double phase) {
    final t = (_controller.value + phase) % 1.0;
    return Opacity(
      opacity: (1 - t) * 0.5,
      child: Container(
        width: 56 + t * 84,
        height: 56 + t * 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.accent.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}
