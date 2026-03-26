import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroTitle extends StatelessWidget {
  final Munro munro;
  const MunroTitle({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsState>();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.sizeOf(context).width - 115,
          child: AutoSizeText(
            munro.name,
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            minFontSize: 22,
            overflowReplacement: AutoSizeText(
              munro.name,
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                letterSpacing: -0.5,
                fontWeight: FontWeight.w400,
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
