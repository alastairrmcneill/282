import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class FollowersFollowingText extends StatelessWidget {
  final int followersCount;
  final int followingCount;
  const FollowersFollowingText({
    super.key,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    FollowingState followingState = Provider.of<FollowingState>(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FollowersFollowingScreen(),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Following",
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                  Text(
                    followingCount.toString(),
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const VerticalDivider(
                color: Colors.black45,
                endIndent: 10,
                indent: 10,
                width: 20,
                thickness: 0.5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Followers",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    followersCount.toString(),
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
