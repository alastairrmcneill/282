import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class ExploreHeaderGroupButton extends StatelessWidget {
  const ExploreHeaderGroupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    NavigationState navigationState = Provider.of<NavigationState>(context, listen: false);
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context);

    bool showNewIcon = RemoteConfigService.getBool(RCFields.groupFilterNewIcon);

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.all(13),
                  side: const BorderSide(
                    color: MyColors.accentColor,
                    width: 0.5,
                  ),
                ),
                onPressed: () {
                  if (userId == null) {
                    navigationState.setNavigateToRoute = HomeScreen.route;
                    Navigator.of(context).pushNamed(AuthHomeScreen.route);
                  } else {
                    Navigator.of(context).pushNamed(GroupFilterScreen.route);
                  }
                },
                child: const Icon(
                  CupertinoIcons.person_2,
                  color: MyColors.accentColor,
                  size: 20,
                ),
              ),
            ),
          ),
          if (showNewIcon && groupFilterState.selectedFriendsUids.isEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                  child: Center(
                    child: Text(
                      'New',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (groupFilterState.selectedFriendsUids.isNotEmpty)
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
