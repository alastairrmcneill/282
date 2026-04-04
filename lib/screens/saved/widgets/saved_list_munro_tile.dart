import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/munro_model.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SavedListMunroTile extends StatelessWidget {
  final Munro munro;
  final Future<void> Function()? onDelete;
  const SavedListMunroTile({super.key, required this.munro, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.read<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colors.border, width: 0.65),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: munro.pictureURL,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(munro.name, style: textTheme.titleLarge),
                Row(
                  children: [
                    Text(
                      settingsState.metricHeight
                          ? "${munro.meters.thousandsSeparator()}m"
                          : "${munro.feet.thousandsSeparator()}ft",
                      style: textTheme.bodySmall?.copyWith(color: context.colors.textSubtitle),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('•', style: textTheme.bodySmall?.copyWith(color: context.colors.textSubtitle)),
                    ),
                    Text(
                      munro.area,
                      style: textTheme.bodySmall?.copyWith(color: context.colors.textSubtitle),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: 16,
            icon: Icon(
              PhosphorIconsRegular.x,
              color: context.colors.textMuted,
            ),
            onPressed: () => onDelete?.call(),
          )
        ],
      ),
    );
  }
}
