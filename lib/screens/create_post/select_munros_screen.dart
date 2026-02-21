import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

// Design System Colors
class AppColors {
  // Emerald (Primary)
  static const emerald50 = Color(0xFFF0FDF4);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);

  // Slate (Neutral)
  static const slate50 = Color(0xFFF8FAFC);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate400 = Color(0xFF94A3B8);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate900 = Color(0xFF0F172A);
}

// Reusable Munro Card Component
class TestMunroCard extends StatelessWidget {
  final Munro munro;
  final bool isSelected;
  final bool isMain;
  final VoidCallback? onTap;

  const TestMunroCard({
    super.key,
    required this.munro,
    this.isSelected = false,
    this.isMain = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = isSelected || isMain ? AppColors.emerald50 : Colors.white;
    Color borderColor = isMain
        ? AppColors.emerald200
        : isSelected
            ? AppColors.emerald300
            : AppColors.slate200;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: Row(
          children: [
            if (isMain)
              Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.emerald600,
              )
            else
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: isSelected ? AppColors.emerald600 : AppColors.slate400,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    munro.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.slate900,
                    ),
                  ),
                  Text(
                    "${munro.area} - ${munro.meters}m",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Header Component
class SectionHeader extends StatelessWidget {
  final String text;

  const SectionHeader({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.slate900,
      ),
    );
  }
}

class SelectMunrosScreen extends StatefulWidget {
  const SelectMunrosScreen({super.key});
  static const String route = '/posts/select-munros';

  @override
  State<SelectMunrosScreen> createState() => _SelectMunrosScreenState();
}

class _SelectMunrosScreenState extends State<SelectMunrosScreen> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final createPostState = context.watch<CreatePostState>();

    Munro mainMunro = munroState.munroList.where((munro) => munro.id == munroState.selectedMunroId).first;

    List<Munro> commonlyClimbedWith = munroState.munroList
        .where((munro) => mainMunro.commonlyClimbedWith.map((e) => e.climbedWithId).contains(munro.id))
        .toList();

    List<Munro> otherMunros = munroState.munroList
        .where((munro) => munro.id != mainMunro.id && !commonlyClimbedWith.map((e) => e.id).contains(munro.id))
        .toList();

    var selectedMunroIds = createPostState.selectedMunroIds;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.1,
        centerTitle: true,
        title: const Text(
          'Climbed Together?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.slate900,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select any munros you climbed with ${mainMunro.name}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Munro Card
                  TestMunroCard(
                    munro: mainMunro,
                    isMain: true,
                  ),
                  const SizedBox(height: 24),

                  // Often Climbed Together Section
                  if (commonlyClimbedWith.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: SectionHeader(text: 'Often Climbed Together'),
                    ),
                    ...commonlyClimbedWith.map((munro) {
                      bool selected = selectedMunroIds.contains(munro.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TestMunroCard(
                          munro: munro,
                          isSelected: selected,
                          onTap: () {
                            if (selected) {
                              createPostState.removeMunro(munro.id);
                            } else {
                              createPostState.addMunro(munro.id);
                            }
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Other Munros Section
                  if (_expanded) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SectionHeader(text: 'Other Munros'),
                          GestureDetector(
                            onTap: () => setState(() => _expanded = false),
                            child: const Text(
                              'Hide',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.emerald600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...otherMunros.map((munro) {
                      bool selected = selectedMunroIds.contains(munro.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TestMunroCard(
                          munro: munro,
                          isSelected: selected,
                          onTap: () {
                            if (selected) {
                              createPostState.removeMunro(munro.id);
                            } else {
                              createPostState.addMunro(munro.id);
                            }
                          },
                        ),
                      );
                    }),
                  ] else
                    InkWell(
                      onTap: () => setState(() => _expanded = true),
                      borderRadius: BorderRadius.circular(8),
                      child: Ink(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.slate200, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Other Munros',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.slate900,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: AppColors.slate400,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Continue Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.slate200, width: 1),
              ),
            ),
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.read<Analytics>().track(AnalyticsEvent.selectCommonlyClimbedMunros, props: {
                    AnalyticsProp.munroId: mainMunro.id,
                    AnalyticsProp.commonlyClimbedWithCount: commonlyClimbedWith.length,
                    AnalyticsProp.selectedMunroCount: createPostState.selectedMunroIds.length,
                  });
                  Navigator.of(context).pushNamed(CreatePostScreen.route);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
