import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LoadingSliverHeader extends StatelessWidget {
  const LoadingSliverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          children: [
            const ShimmerBox(width: 80, height: 80, borderRadius: 40),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBox(width: 90, height: 16, borderRadius: 4),
                const SizedBox(width: 16),
                ShimmerBox(width: 90, height: 16, borderRadius: 4),
              ],
            ),
            const SizedBox(height: 16),
            ShimmerBox(width: double.infinity, height: 38, borderRadius: 8),
          ],
        ),
      ),
    );
  }
}
