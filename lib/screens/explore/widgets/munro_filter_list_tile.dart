import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroFilterListTile extends StatelessWidget {
  final Munro munro;
  final Function(Munro munro) onSelected;
  const MunroFilterListTile({super.key, required this.munro, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);
    return GestureDetector(
      onTap: () {
        munroState.setFilterString = "";
        onSelected(munro);
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: MyColors.backgroundColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  munro.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.2),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        munro.area,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        settingsState.metricHeight ? '${munro.meters}m' : '${munro.feet}ft',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
