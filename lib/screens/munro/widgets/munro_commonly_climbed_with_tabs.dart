import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroCommonlyClimbedWithVertical extends StatelessWidget {
  final Munro munro;
  const MunroCommonlyClimbedWithVertical({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();

    List<Munro> commonlyClimbedWith = munroState.munroList
        .where((m) => munro.commonlyClimbedWith.map((e) => e.climbedWithId).contains(m.id))
        .toList();

    final textTheme = Theme.of(context).textTheme;
    final settingsState = context.read<SettingsState>();

    if (commonlyClimbedWith.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Often climbed with',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        ...commonlyClimbedWith.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      MunroScreen.route,
                      arguments: MunroScreenArgs(munro: m),
                    );
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: m.pictureURL,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  settingsState.metricHeight
                                      ? '${m.meters.thousandsSeparator()} m'
                                      : '${m.feet.thousandsSeparator()} ft',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: context.colors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '•',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: context.colors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  m.area,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: context.colors.textMuted,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Icon(
                        PhosphorIconsRegular.caretRight,
                        color: context.colors.textMuted,
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
