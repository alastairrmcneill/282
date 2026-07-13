import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/achievements/state/achievements_state.dart';
import 'package:two_eight_two/screens/achievements/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class AchievementsCompletedDialog extends StatefulWidget {
  final List<Achievement> recentlyCompletedAchievements;
  const AchievementsCompletedDialog({super.key, required this.recentlyCompletedAchievements});

  @override
  State<AchievementsCompletedDialog> createState() => _AchievementsCompletedDialogState();
}

class _AchievementsCompletedDialogState extends State<AchievementsCompletedDialog> {
  late ConfettiController _confettiController;
  late PageController _pageController;
  int _currentPage = 0;

  bool get _multiple => widget.recentlyCompletedAchievements.length > 1;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _pageController = PageController(viewportFraction: _multiple ? 0.85 : 1.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _confettiController.play());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _acknowledgeAndPop() {
    final achievementsState = context.read<AchievementsState>();
    for (final achievement in widget.recentlyCompletedAchievements) {
      achievementsState.acknowledgeAchievement(achievement: achievement);
    }
    Navigator.of(context).pop();
  }

  void _navigateToAchievements() {
    final achievementsState = context.read<AchievementsState>();
    for (final achievement in widget.recentlyCompletedAchievements) {
      achievementsState.acknowledgeAchievement(achievement: achievement);
    }
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(AchievementListScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            gravity: 0.08,
            numberOfParticles: 24,
            emissionFrequency: 0.04,
            colors: const [
              Color(0xFFEF4444),
              Color(0xFF3B82F6),
              Color(0xFF10B981),
              Color(0xFFF59E0B),
              Color(0xFF8B5CF6),
              Color(0xFFF97316),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'You nailed it!',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _multiple
                          ? 'New badges have been added to your profile.'
                          : 'A new badge has been added to your profile.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.recentlyCompletedAchievements.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (_, i) => _buildBadgePage(
                          context,
                          widget.recentlyCompletedAchievements[i],
                        ),
                      ),
                    ),
                    if (_multiple) ...[
                      const SizedBox(height: 14),
                      _buildDots(context),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: context.colors.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _acknowledgeAndPop,
                        child: const Text('Woohoo! 🎉', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, color: amber, size: 14),
          const SizedBox(width: 8),
          const Text(
            'ACHIEVEMENT UNLOCKED',
            style: TextStyle(
              color: amber,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.auto_awesome, color: amber, size: 14),
        ],
      ),
    );
  }

  Widget _buildBadgePage(BuildContext context, Achievement achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _navigateToAchievements,
            child: AchievementBadgeIcon(
              achievement: achievement,
              containerSize: 120,
              iconSize: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            achievement.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDots(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.recentlyCompletedAchievements.length,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == i ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == i ? context.colors.accent : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
