import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class ProfileMunrosCompletedWidget extends StatelessWidget {
  final double width;
  final double height;
  const ProfileMunrosCompletedWidget({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context);

    // TODO: This will always show your completion. Need it to load for other users
    int count = 282;
    int progress = munroCompletionState.munroCompletions.map((e) => e.munroId).toSet().length;

    return ClickableStatBox(
      onTap: () => Navigator.of(context).pushNamed(MunrosCompletedScreen.route),
      progress: progress.toString(),
      count: " / $count",
      subtitle: "Completed",
    );
  }
}
