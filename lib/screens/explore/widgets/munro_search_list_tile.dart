import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSearchListTile extends StatelessWidget {
  final Munro munro;
  const MunroSearchListTile({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroDetailState = context.watch<MunroDetailState>();
    final settingsState = context.watch<SettingsState>();

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
        munroDetailState.loadMunroPictures(munroId: munro.id, count: 4);
        context.read<ReviewsState>().getMunroReviews();
        Navigator.of(context).pushNamed(MunroScreen.route);
      },
    );
  }
}
