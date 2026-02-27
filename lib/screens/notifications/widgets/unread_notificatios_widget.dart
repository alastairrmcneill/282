import 'package:flutter/material.dart';

class UnreadNotificatiosWidget extends StatelessWidget {
  final int count;
  const UnreadNotificatiosWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Text(
        '$count unread notification${count == 1 ? '' : 's'}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color.fromARGB(178, 0, 0, 0)),
      ),
    );
  }
}
