import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSaveButton extends StatelessWidget {
  final Munro munro;
  const MunroSaveButton({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    final munroState = context.watch<MunroState>();

    final savedListState = context.watch<SavedListState>();
    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Background color
          shape: const CircleBorder(), // Circular shape
          elevation: 3, // Drop shadow
          padding: const EdgeInsets.all(2), // Adjust padding to make it circular
        ),
        onPressed: () async {
          context.read<Analytics>().track(AnalyticsEvent.saveMunroButtonClicked, props: {
            AnalyticsProp.source: "Munro Page",
            AnalyticsProp.munroId: munro.id,
            AnalyticsProp.munroName: munro.name,
          });
          if (userId == null) {
            Navigator.pushNamed(context, AuthHomeScreen.route);
          } else {
            munroState.setSelectedMunro = munro;
            showSaveMunroDialog(context);
          }
        },
        child: Icon(
          munroSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          color: MyColors.accentColor,
          size: 20,
        ),
      ),
    );
  }
}
