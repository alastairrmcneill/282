import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunrosCommonlyClimbedWithGrid extends StatelessWidget {
  final Munro munro;

  const MunrosCommonlyClimbedWithGrid({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final settingsState = context.read<SettingsState>();

    final List<Munro> commonlyClimbedWith = munroState.munroList
        .where((m) => munro.commonlyClimbedWith.map((e) => e.climbedWithId).contains(m.id))
        .toList();

    if (commonlyClimbedWith.isEmpty) {
      return const SizedBox();
    }

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Often Climbed Together', style: textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: commonlyClimbedWith.length,
          itemBuilder: (context, index) {
            return MunroClimbedWithTile(
              munro: commonlyClimbedWith[index],
              settingsState: settingsState,
            );
          },
        ),
      ],
    );
  }
}
