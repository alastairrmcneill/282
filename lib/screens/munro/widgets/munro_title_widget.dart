import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:share_plus/share_plus.dart';

class MunroTitle extends StatelessWidget {
  const MunroTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    final munroDetailState = context.read<MunroDetailState>();
    final savedListState = context.watch<SavedListState>();

    Munro munro = munroDetailState.selectedMunro!;
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
              munro.extra == null || munro.extra == ""
                  ? const SizedBox()
                  : SizedBox(
                      width: double.infinity,
                      child: Text(
                        "(${munro.extra})",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            final link = await context.read<ShareState>().createMunroLink(
                  munroId: munro.id,
                  munroName: munro.name,
                );

            if (link == null) {
              showSnackBar(context, 'Failed to share link.');
              return;
            }

            await SharePlus.instance.share(ShareParams(text: 'Check out ${munro.name} - $link'));
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
            context.read<Analytics>().track(AnalyticsEvent.saveMunroButtonClicked, props: {
              AnalyticsProp.source: "Munro Tile",
              AnalyticsProp.munroId: (munro.id).toString(),
              AnalyticsProp.munroName: munro.name,
            });

            if (userId == null) {
              Navigator.pushNamed(context, AuthHomeScreen.route);
            } else {
              await SaveMunroBottomSheet.show(context);
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
