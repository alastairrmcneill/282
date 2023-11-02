import 'package:flutter/material.dart';
import 'package:two_eight_two/features/home/feed/screens/screens.dart';

class FeedTab extends StatelessWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserSearchScreen(),
                ),
              );
            },
            icon: Icon(Icons.search))
      ]),
      body: Center(
        child: Text('Feed Tab'),
      ),
    );
  }
}
