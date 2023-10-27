import 'package:flutter/material.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';

class FollowersFollowingText extends StatelessWidget {
  const FollowersFollowingText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FollowersFollowingScreen(),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        child: const IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Following",
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                  Text(
                    "0",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              VerticalDivider(
                color: Colors.black45,
                endIndent: 10,
                indent: 10,
                width: 20,
                thickness: 0.5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Following",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "0",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
