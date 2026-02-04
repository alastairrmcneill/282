import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class FinalScreen extends StatefulWidget {
  final VoidCallback? onGetStarted;

  const FinalScreen({super.key, this.onGetStarted});

  @override
  State<FinalScreen> createState() => _FinalScreenState();
}

class _FinalScreenState extends State<FinalScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _bounceController;
  late List<AnimationController> _sparkleControllers;

  late Animation<double> _mountainScaleAnimation;
  late Animation<double> _mountainRotateAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _statsAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller for initial entrance
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Bounce controller for continuous mountain bouncing
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Sparkle controllers (8 sparkles with staggered animations)
    _sparkleControllers = List.generate(8, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      )..repeat();
    });

    // Start sparkle animations with delays
    for (var i = 0; i < _sparkleControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 400), () {
        if (mounted) {
          _sparkleControllers[i].forward();
        }
      });
    }

    _mountainRotateAnimation = Tween<double>(begin: -math.pi, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _mountainScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
      ),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bounceController.dispose();
    for (var controller in _sparkleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1761660227639-d31677e681d3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzY290dGlzaCUyMG1vdW50YWluJTIwc3VtbWl0JTIwc3VucmlzZXxlbnwxfHx8fDE3NzAyMDMxMzF8MA&ixlib=rb-4.1.0&q=80&w=1080',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: Colors.grey[800]);
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
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Floating sparkles
        ..._buildSparkles(),
        // Content
        Positioned(
          left: 0,
          right: 0,
          bottom: 96,
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  // Mountain icon with bounce
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _mainController,
                      _bounceController,
                    ]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: Transform.rotate(
                          angle: _mountainRotateAnimation.value,
                          child: Transform.scale(
                            scale: _mountainScaleAnimation.value,
                            child: child,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6ee7b7), Color(0xFF14b8a6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10b981).withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.mountain,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    child: Column(
                      children: [
                        const Text(
                          'Ready to Start Your Adventure?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '282 peaks are waiting. Your story begins with the first step.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFFe2e8f0),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  AnimatedBuilder(
                    animation: _statsAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.9 + (0.1 * _statsAnimation.value),
                        child: Opacity(
                          opacity: _statsAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              const Text(
                                '12,847',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Baggers',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFcbd5e1),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            color: Colors.white.withOpacity(0.2),
                          ),
                          Column(
                            children: [
                              const Text(
                                '84,392',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Summits',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFcbd5e1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Footer text
                  AnimatedBuilder(
                    animation: _statsAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _statsAnimation.value,
                        child: child,
                      );
                    },
                    child: const Text(
                      'Join the community of baggers conquering Scotland\'s peaks 🏴󠁧󠁢󠁳󠁣󠁴󠁿',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFcbd5e1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSparkles() {
    return List.generate(8, (index) {
      final left = 15.0 + (index * 12.0);

      return Positioned(
        left: MediaQuery.of(context).size.width * (left / 100),
        bottom: MediaQuery.of(context).size.height * 0.35,
        child: AnimatedBuilder(
          animation: _sparkleControllers[index],
          builder: (context, child) {
            final value = _sparkleControllers[index].value;
            return Transform.translate(
              offset: Offset(0, -100 * value + 20),
              child: Opacity(
                opacity: value < 0.5 ? value * 2 : (1 - value) * 2,
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 16,
                  color: Color(0xFFfcd34d),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
