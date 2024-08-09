import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MunroSearchListTile extends StatelessWidget {
  final Munro munro;
  const MunroSearchListTile({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(munro.name),
      subtitle: Row(
        children: [
          Text(
            "${munro.area} · ${settingsState.metricHeight ? "${munro.meters}m" : "${munro.feet}ft"} · ",
          ),
          MunroRatingText(munro: munro, showReviewCount: false)
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
  }
}
