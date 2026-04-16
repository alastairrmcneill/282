import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/onboarding/widgets/onboarding_buttons.dart';

class AchievementScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AchievementScreen({super.key, required this.onNext, required this.onBack});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _trophyScaleAnimation;
  late Animation<double> _trophyRotateAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _achievement1Animation;
  late Animation<double> _achievement2Animation;
  late Animation<double> _achievement3Animation;
  late Animation<double> _achievement4Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _trophyRotateAnimation = Tween<double>(begin: -math.pi, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _trophyScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _achievement1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeOut),
      ),
    );

    _achievement2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
      ),
    );

    _achievement3Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeOut),
      ),
    );

    _achievement4Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 0.9, curve: Curves.easeOut),
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
    final state = context.watch<OnboardingState>();
    return Stack(
      children: [
        // Background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1764377725269-a26ada9b551a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb3VudGFpbiUyMGNsaW1iZXIlMjBzdW1taXQlMjBhY2hpZXZlbWVudHxlbnwxfHx8fDE3NzAyMDM5NzR8MA&ixlib=rb-4.1.0&q=80&w=1080',
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
          bottom: 80,
          child: RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Trophy icon
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _trophyRotateAnimation.value,
                        child: Transform.scale(
                          scale: _trophyScaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFf59e0b).withOpacity(0.2),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.trophy,
                              size: 40,
                              color: Color(0xFFfbbf24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                          'Unlock Achievements',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Earn badges and celebrate milestones as you climb',
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
                  const SizedBox(height: 20),
                  // Achievement cards
                  _buildAchievementCard(
                    animation: _achievement1Animation,
                    icon: LucideIcons.target,
                    title: state.achievements[0].name,
                    description: state.achievements[0].description,
                    locked: false,
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementCard(
                    animation: _achievement2Animation,
                    icon: LucideIcons.star,
                    title: state.achievements[1].name,
                    description: state.achievements[1].description,
                    locked: false,
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementCard(
                    animation: _achievement3Animation,
                    icon: LucideIcons.trophy,
                    title: state.achievements[2].name,
                    description: state.achievements[2].description,
                    locked: true,
                  ),
                  const SizedBox(height: 10),
                  _buildAchievementCard(
                    animation: _achievement4Animation,
                    icon: LucideIcons.award,
                    title: state.achievements[3].name,
                    description: state.achievements[3].description,
                    locked: true,
                  ),
                  const SizedBox(height: 32),
                  // Navigation buttons
                  OnboardingNavigationButtons(
                    onNext: widget.onNext,
                    onBack: widget.onBack,
                    nextText: 'Continue',
                    backButtonLight: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required Animation<double> animation,
    required IconData icon,
    required String title,
    required String description,
    required bool locked,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-50 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: locked
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF6ee7b7), Color(0xFF14b8a6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: locked ? Colors.grey[600] : null,
                    boxShadow: locked
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFF10b981).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFcbd5e1),
                        ),
                      ),
                    ],
                  ),
                ),
                locked
                    ? const Text(
                        '🔒',
                        style: TextStyle(fontSize: 20),
                      )
                    : const Icon(
                        LucideIcons.star,
                        size: 16,
                        color: Color(0xFFfbbf24),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
