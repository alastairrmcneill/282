import 'package:flutter/material.dart';

class OverlayGradient extends StatelessWidget {
  final List<double> stops;

  const OverlayGradient({
    super.key,
    this.stops = const [0.6, 0.7, 1.0],
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: stops,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.6),
            ],
          ),
        ),
      ),
    );
  }
}
