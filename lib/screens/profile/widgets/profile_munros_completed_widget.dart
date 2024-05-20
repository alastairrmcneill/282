import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
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
    int progress = profileState.user?.personalMunroData?.where((munro) => munro[MunroFields.summited]).length ?? 0;

    return ClickableStatBox(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MunrosCompletedScreen()),
        );
      },
      count: count.toString(),
      progress: progress.toString(),
      subtitle: "Completed",
    );
  }
}
