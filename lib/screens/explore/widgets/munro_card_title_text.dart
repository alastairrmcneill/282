import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroCardTitleText extends StatelessWidget {
  final Munro munro;
  const MunroCardTitleText({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    return Expanded(
      flex: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            munro.name,
            maxLines: 2,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontWeight: FontWeight.w800, height: 1.1, fontSize: 16),
          ),
          munro.extra == null || munro.extra == ""
              ? const SizedBox()
              : Text(
                  "(${munro.extra})",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                ),
          const SizedBox(height: 4),
          Text(
            "${munro.area} · ${settingsState.metricHeight ? "${munro.meters}m" : "${munro.feet}ft"}",
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
