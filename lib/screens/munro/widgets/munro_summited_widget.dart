import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummitedWidget extends StatelessWidget {
  const MunroSummitedWidget({super.key});

  Widget _buildBody(
    BuildContext context,
    List<MunroCompletion> completions,
  ) {
    if (completions.isEmpty) {
      return RichText(
        text: TextSpan(
          text: "You have not bagged this Munro yet.",
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18, height: 1.45),
        ),
      );
    }
    if (completions.length == 1) {
      DateTime date = completions.first.dateTimeCompleted;

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
              text: " ${completions.length}",
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
    final userState = context.watch<UserState>();
    final munroDetailState = context.watch<MunroDetailState>();
    final munroCompletionState = context.watch<MunroCompletionState>();

    List<MunroCompletion> completions =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munroDetailState.selectedMunro!.id).toList();

    return InkWell(
      onTap: () {
        if (userState.currentUser == null) {
          Navigator.of(context).pushNamed(AuthHomeScreen.route);
        } else {
          if (munroDetailState.selectedMunro != null) {
            Navigator.of(context).pushNamed(MunroSummitsScreen.route);
          }
        }
      },
      child: Container(
        color: Colors.transparent,
        child: _buildBody(context, completions),
      ),
    );
  }
}
