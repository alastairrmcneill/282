import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ShimmerListTile extends StatelessWidget {
  const ShimmerListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: ShimmerBox(
        width: 24,
        height: 24,
        borderRadius: 24,
      ),
      title: ShimmerBox(
        height: 16,
        width: double.infinity,
        borderRadius: 5,
      ),
      subtitle: ShimmerBox(
        height: 10,
        width: double.infinity,
        borderRadius: 2,
      ),
    );
  }
}
