import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroTitle extends StatelessWidget {
  const MunroTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    SavedListState savedListState = Provider.of<SavedListState>(context);

    Munro munro = munroState.selectedMunro!;
    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(munro.name, style: Theme.of(context).textTheme.headlineMedium),
              munroState.selectedMunro?.extra == null || munroState.selectedMunro?.extra == ""
                  ? const SizedBox()
                  : SizedBox(
                      width: double.infinity,
                      child: Text(
                        "(${munroState.selectedMunro?.extra})",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            await DeepLinkService.shareMunro(context, munro.name, munro.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              CupertinoIcons.share,
              color: MyColors.accentColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            AnalyticsService.logEvent(
              name: "Save MunroButton Clicked",
              parameters: {
                "source": "Munro Summary Tile",
                "munro_id": munroState.selectedMunro?.id ?? "",
                "munro_name": munroState.selectedMunro?.name ?? "",
                "user_id": user?.uid ?? "",
              },
            );
            if (user == null) {
              navigationState.setNavigateToRoute = HomeScreen.route;
              Navigator.pushNamed(context, AuthHomeScreen.route);
            } else {
              showSaveMunroDialog(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              munroSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
              color: MyColors.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
