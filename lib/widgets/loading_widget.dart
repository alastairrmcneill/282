import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String? text;
  final double size;

  const LoadingWidget({
    super.key,
    this.text = 'Loading...',
    this.size = 128,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> with TickerProviderStateMixin {
  late AnimationController _pathController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    // Path drawing animation
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: false);

    // Text pulsing animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pathController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: AnimatedBuilder(
              animation: _pathController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _MountainPathPainter(
                    pathProgress: _pathController.value,
                  ),
                );
              },
            ),
          ),
          if (widget.text != null) ...[
            const SizedBox(height: 24),
            FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(
                  parent: _textController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Text(
                widget.text!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MountainPathPainter extends CustomPainter {
  final double pathProgress;

  _MountainPathPainter({required this.pathProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define the mountain path
    final mountainPath = Path()
      ..moveTo(0, height)
      ..lineTo(width * 0.25, height * 0.5)
      ..lineTo(width * 0.5, height * 0.75)
      ..lineTo(width * 0.75, height * 0.25)
      ..lineTo(width, height)
      ..close();

    // Draw static mountain outline (filled)
    final mountainPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;

    canvas.drawPath(mountainPath, mountainPaint);

    // Draw animated dotted path
    final animatedPath = Path()
      ..moveTo(0, height)
      ..lineTo(width * 0.25, height * 0.5)
      ..lineTo(width * 0.5, height * 0.75)
      ..lineTo(width * 0.75, height * 0.25);

    final pathMetric = animatedPath.computeMetrics().first;
    final extractPath = pathMetric.extractPath(
      0,
      pathMetric.length * pathProgress,
    );

    final pathPaint = Paint()
      ..color = const Color(0xFF059669) // Emerald green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw solid line
    canvas.drawPath(extractPath, pathPaint);
  }

  @override
  bool shouldRepaint(_MountainPathPainter oldDelegate) {
    return oldDelegate.pathProgress != pathProgress;
  }
}
