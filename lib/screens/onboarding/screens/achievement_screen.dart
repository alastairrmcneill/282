import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _card3Animation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );

    _card1Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.65, curve: Curves.easeOut)),
    );

    _card2Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.75, curve: Curves.easeOut)),
    );

    _card3Animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.85, curve: Curves.easeOut)),
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
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
        // Background image
        Positioned.fill(
          child: Image.network(
            'https://images.unsplash.com/photo-1673886084132-9b5fd8e4acdf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxoaWtpbmclMjBmcmllbmRzJTIwbW91bnRhaW58ZW58MXx8fHwxNzcwMjAzMTA2fDA&ixlib=rb-4.1.0&q=80&w=1080',
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
                  Colors.black.withOpacity(0.15),
                  Colors.black.withOpacity(0.85),
                ],
                stops: const [0.0, 0.45, 1.0],
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
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Icon
                    AnimatedBuilder(
                      animation: _iconAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _iconAnimation.value.clamp(0.0, 1.5),
                        child: Opacity(opacity: _iconAnimation.value.clamp(0.0, 1.0), child: child),
                      ),
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10b981).withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Icon(LucideIcons.users, size: 40, color: Color(0xFF6ee7b7)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Title
                    AnimatedBuilder(
                      animation: _titleAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, 30 * (1 - _titleAnimation.value)),
                        child: Opacity(opacity: _titleAnimation.value, child: child),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Bag more, together',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'See what your friends are climbing, share your proudest moments, and push each other to new heights.',
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
                    _buildFeatureCard(
                      animation: _card1Animation,
                      icon: LucideIcons.share_2,
                      title: 'Share your summits',
                      subtitle: 'Post photos and tag the Munros you conquer',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      animation: _card2Animation,
                      icon: LucideIcons.heart,
                      title: 'Celebrate together',
                      subtitle: 'Like and comment on your friends\' climbs',
                    ),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      animation: _card3Animation,
                      icon: LucideIcons.trophy,
                      title: 'Earn achievements',
                      subtitle: 'Unlock badges and celebrate milestones',
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _buttonAnimation,
                      builder: (context, child) => Opacity(opacity: _buttonAnimation.value, child: child),
                      child: OnboardingNavigationButtons(
                        onNext: widget.onNext,
                        onBack: widget.onBack,
                        nextText: 'Continue',
                        backButtonLight: true,
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

  Widget _buildFeatureCard({
    required Animation<double> animation,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(-30 * (1 - animation.value), 0),
        child: Opacity(opacity: animation.value, child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6ee7b7), Color(0xFF14b8a6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(child: Icon(icon, size: 20, color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13, color: Color(0xFFcbd5e1)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
