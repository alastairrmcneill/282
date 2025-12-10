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
    ProfileState profileState = Provider.of<ProfileState>(context);

    int count = 282;
    int progress = profileState.profile?.munrosCompleted ?? 0;

    return ClickableStatBox(
      onTap: () async {
        await profileState.getProfileMunroCompletions();
        Navigator.of(context).pushNamed(MunrosCompletedScreen.route);
      },
      progress: progress.toString(),
      count: " / $count",
      subtitle: "Completed",
    );
  }
}
