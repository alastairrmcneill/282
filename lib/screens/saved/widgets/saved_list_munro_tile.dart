import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/munro_model.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class SavedListMunroTile extends StatelessWidget {
  final Munro munro;
  final Future<void> Function()? onDelete;
  const SavedListMunroTile({super.key, required this.munro, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final settingState = context.read<SettingsState>();
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
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
                Text(munro.name, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                Text(munro.area, style: textTheme.bodySmall?.copyWith(color: MyColors.mutedText)),
                Text(
                    "${settingState.metricHeight ? munro.meters.thousandsSeparator() : munro.feet.thousandsSeparator()}${settingState.metricHeight ? 'm' : 'ft'}",
                    style: textTheme.bodySmall?.copyWith(color: MyColors.mutedText)),
              ],
            ),
          ),
          IconButton(
            iconSize: 16,
            icon: Icon(
              PhosphorIconsRegular.x,
              color: MyColors.mutedText,
            ),
            onPressed: () => onDelete?.call(),
          )
        ],
      ),
    );
  }
}
