import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroStatsRow extends StatelessWidget {
  const MunroStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    SettingsState settingsState = Provider.of<SettingsState>(context, listen: false);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      // decoration: BoxDecoration(
      //     borderRadius: BorderRadius.circular(10),
      //     gradient: MyColors.linearGradient,
      //     border: Border.all(width: 0.5, color: Color.fromRGBO(228, 230, 222, 1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatText(
            text: "Height",
            stat: settingsState.metricHeight
                ? "${munroState.selectedMunro?.meters}"
                : "${munroState.selectedMunro?.feet}",
            subStat: settingsState.metricHeight ? "m" : "ft",
          ),
          StatText(text: "Area", stat: munroState.selectedMunro?.area ?? ""),
          StatText(
            text: "Rating",
            stat: munroState.selectedMunro?.averageRating?.toStringAsFixed(1) ?? "0",
            subStat: "/5",
          ),
          // StatText(
          //   text: "Summited",
          //   stat: munroState.selectedMunro?.summitedDates?.length.toString() ?? "0",
          //   onTap: () {
          //     if (userState.currentUser == null) {
          //       navigationState.setNavigateToRoute = HomeScreen.route;
          //       Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
          //     } else {
          //       if (munroState.selectedMunro != null) {
          //         Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (_) => const MunroSummitsScreen(),
          //           ),
          //         );
          //       }
          //     }
          //   },
          // )
        ],
      ),
    );
  }
}
