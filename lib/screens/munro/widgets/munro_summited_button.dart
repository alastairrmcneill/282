import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummitedButton extends StatelessWidget {
  const MunroSummitedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final userState = context.read<UserState>();
    final createPostState = context.read<CreatePostState>();
    final settingsState = context.read<SettingsState>();

    return SizedBox(
      width: 150,
      child: FloatingActionButton(
        onPressed: () {
          if (userState.currentUser == null) {
            Navigator.of(context).pushNamed(AuthHomeScreen.route);
          } else {
            createPostState.reset();
            if (munroState.selectedMunro != null) {
              createPostState.addMunro(munroState.selectedMunro!.id);
              createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
              Navigator.of(context).pushNamed(CreatePostScreen.route);
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Add some padding to make the button wider
          child: Text(
            "Bag Munro",
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ), // Set the text color to white
          ),
        ),
      ),
    );
  }
}
