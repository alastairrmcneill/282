import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class SearchMunroScreen extends StatelessWidget {
  const SearchMunroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: MyColors.backgroundColor,
      child: ListView.builder(
        itemCount: munroState.filteredMunroList.length,
        itemBuilder: (context, index) {
          Munro munro = munroState.filteredMunroList[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(munro.name),
            subtitle: Row(
              children: [
                Text(
                  "${munro.area} · ${settingsState.metricHeight ? "${munro.meters}m" : "${munro.feet}ft"} · ",
                ),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      munro.averageRating?.toStringAsFixed(1) ?? "0",
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 12,
                      color: Colors.amber,
                    ),
                  ],
                ),
              ],
            ),
            visualDensity: VisualDensity.comfortable,
            onTap: () {
              munroState.setSelectedMunro = munro;
              MunroPictureService.getMunroPictures(context, munroId: munro.id, count: 4);
              ReviewService.getMunroReviews(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MunroScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
