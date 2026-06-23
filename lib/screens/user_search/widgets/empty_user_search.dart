import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/user_search/widgets/user_search_icon_cluster.dart';

class EmptyUserSearch extends StatelessWidget {
  const EmptyUserSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 40),
      child: Column(
        children: [
          const UserSearchIconCluster(),
          const SizedBox(height: 20),
          Text(
            'Find fellow Munro baggers',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Search by name to connect with other hikers on 282.',
            style: theme.textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
