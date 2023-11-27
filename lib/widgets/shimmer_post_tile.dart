import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ShimmerPostTile extends StatelessWidget {
  const ShimmerPostTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: double.infinity, height: 400, borderRadius: 10),
          SizedBox(height: 10),
          ShimmerBox(width: double.infinity, height: 30, borderRadius: 5),
          SizedBox(height: 5),
          ShimmerBox(width: 300, height: 20, borderRadius: 5),
        ],
      ),
    );
  }
}
