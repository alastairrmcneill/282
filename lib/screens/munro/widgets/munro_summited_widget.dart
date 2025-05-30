import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummitedWidget extends StatelessWidget {
  const MunroSummitedWidget({super.key});

  Widget _buildBody(
      BuildContext context, int count, UserState userState, MunroState munroState, NavigationState navigationState) {
    if (count == 0) {
      return RichText(
        text: TextSpan(
          text: "You have not bagged this Munro yet.",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, height: 1.45),
        ),
      );
    }
    if (count == 1) {
      DateTime date = munroState.selectedMunro?.summitedDates?.first ?? DateTime.now();

      return RichText(
        text: TextSpan(
          text: "You climbed this Munro on ${DateFormat('dd/MM/yyyy').format(date)}!",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, height: 1.45),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: "You've climbed this Munro",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, height: 1.45),
          children: <TextSpan>[
            TextSpan(
              text: " $count",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w700, fontSize: 24, height: 1.45),
            ),
            TextSpan(
              text: " times!",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, height: 1.45),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    MunroState munroState = Provider.of<MunroState>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    int count = munroState.selectedMunro?.summitedDates?.length ?? 0;

    return InkWell(
      onTap: () {
        if (userState.currentUser == null) {
          navigationState.setNavigateToRoute = HomeScreen.route;
          Navigator.of(context).pushNamed(AuthHomeScreen.route);
        } else {
          if (munroState.selectedMunro != null) {
            Navigator.of(context).pushNamed(MunroSummitsScreen.route);
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        child: _buildBody(context, count, userState, munroState, navigationState),
      ),
    );
  }
}
