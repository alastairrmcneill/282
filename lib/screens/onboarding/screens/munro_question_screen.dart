import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class MunroQuestionScreen extends StatefulWidget {
  final VoidCallback onYes;
  final VoidCallback onNo;

  const MunroQuestionScreen({super.key, required this.onYes, required this.onNo});

  @override
  State<MunroQuestionScreen> createState() => _MunroQuestionScreenState();
}

class _MunroQuestionScreenState extends State<MunroQuestionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _button1Animation;
  late Animation<double> _button2Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.45, curve: Curves.elasticOut)),
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background photo
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixlib=rb-4.1.0&q=80&w=1080',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF0f4c35)),
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
                  Color(0x55065f46),
                  Color(0x33065f46),
                  Color(0xdd065f46),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),
        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(left: 32, right: 32, bottom: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedBuilder(
                  animation: _iconAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _iconAnimation.value.clamp(0.0, 1.5),
                    child: Opacity(opacity: _iconAnimation.value.clamp(0.0, 1.0), child: child),
                  ),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: const Center(
                          child: Icon(LucideIcons.mountain, size: 48, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _titleAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, 24 * (1 - _titleAnimation.value)),
                    child: Opacity(opacity: _titleAnimation.value, child: child),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Already a bagger?',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Have you already conquered some of Scotland's 282 Munros?",
                        style: TextStyle(fontSize: 17, color: Color(0xFFd1fae5), height: 1.55),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _button1Animation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, 20 * (1 - _button1Animation.value)),
                    child: Opacity(opacity: _button1Animation.value, child: child),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: FilledButton(
                      onPressed: widget.onYes,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF10b981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
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
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: OutlinedButton(
                          onPressed: widget.onNo,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.5),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}
