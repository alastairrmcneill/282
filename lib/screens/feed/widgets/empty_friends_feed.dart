import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/feed/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class EmptyFriendsFeed extends StatelessWidget {
  const EmptyFriendsFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const FindFriendsHeaderWiget(),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_people_rounded, size: 100),
              const SizedBox(height: 16),
              Text(
                "Connect with other munro baggers!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                "Find your friends or other munro bagging enthusiasts to follow!",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const UserSearchScreen(),
                    ),
                  );
                },
                child: const Text("Find Friends"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
