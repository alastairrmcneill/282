import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'package:intl/intl.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummitedButton extends StatelessWidget {
  const MunroSummitedButton({super.key});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    UserState userState = Provider.of<UserState>(context);
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);

    return munroNotifier.selectedMunro?.summited ?? false
        ? Text("Summited: ${DateFormat('dd/MM/yyyy').format(
            munroNotifier.selectedMunro?.summitedDate ?? DateTime.now(),
          )}")
        : SizedBox(
            height: 44,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (userState.currentUser == null) {
                  navigationState.setNavigateToRoute = "/home_screen";
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
                } else {
                  createPostState.reset();
                  if (munroNotifier.selectedMunro != null) {
                    createPostState.addMunro(munroNotifier.selectedMunro!);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(),
                      ),
                    );
                  }
                }
              },
              child: const Text("Mark as summited"),
            ),
          );
  }
}