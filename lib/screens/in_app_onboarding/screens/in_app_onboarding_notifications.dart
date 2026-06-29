import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class InAppOnboardingNotifications extends StatefulWidget {
  const InAppOnboardingNotifications({super.key});
  static const String route = '/in_app_onboarding/notifications';

  @override
  State<InAppOnboardingNotifications> createState() => _InAppOnboardingNotificationsState();
}

class _InAppOnboardingNotificationsState extends State<InAppOnboardingNotifications>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _card3Animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _iconAnimation,
            builder: (context, child) => Transform.scale(
              scale: _iconAnimation.value.clamp(0.0, 1.5),
              child: Opacity(opacity: _iconAnimation.value.clamp(0.0, 1.0), child: child),
            ),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10b981).withOpacity(0.12),
              ),
              child: const Center(
                child: Icon(LucideIcons.bell, size: 36, color: Color(0xFF10b981)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _titleAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, 20 * (1 - _titleAnimation.value)),
              child: Opacity(opacity: _titleAnimation.value, child: child),
            ),
            child: Column(
              children: [
                Text(
                  'Never miss a moment',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "We'll only notify you about things that matter to your Munro journey.",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _NotificationCard(
            animation: _card1Animation,
            icon: LucideIcons.heart,
            iconColor: const Color(0xFFef4444),
            title: 'Sarah B. liked your summit',
            subtitle: 'Ben Nevis • 2 min ago',
          ),
          const SizedBox(height: 10),
          _NotificationCard(
            animation: _card2Animation,
            icon: LucideIcons.users,
            iconColor: const Color(0xFF3b82f6),
            title: 'James followed you',
            subtitle: 'Fellow bagger, 47 Munros • just now',
          ),
          const SizedBox(height: 10),
          _NotificationCard(
            animation: _card3Animation,
            icon: LucideIcons.trophy,
            iconColor: const Color(0xFFf59e0b),
            title: 'Milestone: 50 Munros bagged! 🏆',
            subtitle: 'You\'ve unlocked the Half Century badge',
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Animation<double> animation;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _NotificationCard({
    required this.animation,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(30 * (1 - animation.value), 0),
        child: Opacity(opacity: animation.value, child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.12),
              ),
              child: Center(child: Icon(icon, size: 20, color: iconColor)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF10b981),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
