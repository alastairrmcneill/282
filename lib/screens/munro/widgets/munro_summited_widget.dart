import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroSummitedWidget extends StatelessWidget {
  const MunroSummitedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    int count = munroState.selectedMunro?.summitedDates?.length ?? 0;

    if (count == 0) {
      return RichText(
        text: TextSpan(
          text: "You have not bagged this Munro yet.",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
        ),
      );
    }
    if (count == 1) {
      DateTime date = munroState.selectedMunro?.summitedDates?.first ?? DateTime.now();

      return RichText(
        text: TextSpan(
          text: "You climbed this Munro on ${DateFormat('dd/MM/yyyy').format(date)}!",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: "You've climbed this Munro",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
          children: <TextSpan>[
            TextSpan(
              text: " $count",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
            ),
            TextSpan(
              text: " times!",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18),
            ),
          ],
        ),
      );
    }
  }
}
