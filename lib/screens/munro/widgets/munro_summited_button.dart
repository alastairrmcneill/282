import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'package:intl/intl.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummitedButton extends StatelessWidget {
  const MunroSummitedButton({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);

    return SizedBox(
      width: 150,
      child: FloatingActionButton(
        onPressed: () {
          if (userState.currentUser == null) {
            navigationState.setNavigateToRoute = HomeScreen.route;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
          } else {
            createPostState.reset();
            if (munroState.selectedMunro != null) {
              createPostState.addMunro(munroState.selectedMunro!);
              navigationState.setNavigateToRoute = HomeScreen.route;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(),
                ),
              );
            }
          }
        },
        backgroundColor: Color.fromRGBO(231, 141, 8, 1), // Set the background color to orange
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15), // Set the border radius to make the button rounded
          ),
        ),
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
