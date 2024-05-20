import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';

class ProfileMunroStats extends StatelessWidget {
  const ProfileMunroStats({super.key});

  @override
  Widget build(BuildContext context) {
    double width = (MediaQuery.of(context).size.width - 150) / 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ProfileMunrosCompletedWidget(
            width: width,
            height: width,
          ),
          ProfileMunroChallengeWidget(
            width: width,
            height: width,
          ),
        ],
      ),
    );
  }
}
