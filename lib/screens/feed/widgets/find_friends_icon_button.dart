import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:two_eight_two/screens/screens.dart';

class FindFriendsIconButton extends StatelessWidget {
  const FindFriendsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const UserSearchScreen(),
          ),
        );
      },
      icon: const Icon(
        CupertinoIcons.search,
        size: 22,
      ),
    );
  }
}
