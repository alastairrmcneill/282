import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart' show IntExtension;
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroCardTitleText extends StatelessWidget {
  final Munro munro;
  const MunroCardTitleText({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width - 30,
          child: AutoSizeText(
            munro.name,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w500,
              fontSize: 22,
            ),
            maxLines: 1,
            minFontSize: 20,
            overflowReplacement: AutoSizeText(
              munro.name,
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.star_rounded, size: 16, color: MyColors.starColor),
            Text(
              (munro.averageRating ?? 0).toStringAsFixed(1),
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '•',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              settingsState.metricHeight
                  ? '${munro.meters.thousandsSeparator()} m'
                  : '${munro.feet.thousandsSeparator()} ft',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '•',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              munro.area,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        )
      ],
    );
  }
}
