import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroChallengeCompleteScreen extends StatelessWidget {
  const MunroChallengeCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroChallengeState munroChallengeState = Provider.of<MunroChallengeState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Munro Challenge Complete'),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Congratulations! You have completed your ${munroChallengeState.currentMunroChallenge!.year} Munro Challenge of ${munroChallengeState.currentMunroChallenge!.target} Munros!"),
            Text("You have completed ${munroChallengeState.currentMunroChallenge!.completedMunros.length} Munros"),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home_screen", // The name of the route you want to navigate to
                  (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                );
              },
              child: const Text('Close'),
            )
          ],
        ),
      ),
    );
  }
}
