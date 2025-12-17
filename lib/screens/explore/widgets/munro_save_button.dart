import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSaveButton extends StatelessWidget {
  final Munro munro;
  const MunroSaveButton({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    NavigationState navigationState = Provider.of(context);
    MunroState munroState = Provider.of<MunroState>(context);

    SavedListState savedListState = Provider.of<SavedListState>(context);
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
          AnalyticsService.logEvent(
            name: "Save Munro Button Clicked",
            parameters: {
              "source": "Munro Page",
              "munro_id": (munroState.selectedMunro?.id ?? 0).toString(),
              "munro_name": munroState.selectedMunro?.name ?? "",
              "user_id": userId ?? "",
            },
          );
          if (userId == null) {
            navigationState.setNavigateToRoute = HomeScreen.route;
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
