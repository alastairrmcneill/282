import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/user_search/user_search_screen.dart';

class FindFriendsHeaderWiget extends StatelessWidget {
  const FindFriendsHeaderWiget({super.key});

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Find your friends!",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          AppSearchBar(
            focusNode: focusNode,
            onClear: () {},
            hintText: "Search...",
            onSearchTap: () {
              focusNode.unfocus();
              Navigator.of(context).pushNamed(UserSearchScreen.route);
            },
          )
        ],
      ),
    );
  }
}
