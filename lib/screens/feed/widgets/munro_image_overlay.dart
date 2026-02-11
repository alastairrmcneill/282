import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/int_extension.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroImageOverlay extends StatelessWidget {
  final Munro munro;
  const MunroImageOverlay({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsState>();

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro)),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withAlpha(170),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.map_pin, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  munro.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
                Text(
                  settingsState.metricHeight
                      ? "${munro.meters.thousandsSeparator()}m"
                      : "${munro.feet.thousandsSeparator()}ft",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
