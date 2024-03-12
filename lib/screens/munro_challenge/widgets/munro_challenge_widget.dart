import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroChallengeWidget extends StatelessWidget {
  final Achievement achievement;
  const MunroChallengeWidget({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: Colors.blue[50],
      child: Column(
        children: [
          Text(achievement.name),
          Text(achievement.description),
          achievement.completed ? const Icon(Icons.check) : const SizedBox(),
        ],
      ),
    );
  }
}
