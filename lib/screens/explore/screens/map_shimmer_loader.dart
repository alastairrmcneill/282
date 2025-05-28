import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MapShimmerLoader extends StatelessWidget {
  const MapShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Shimmering base "map" with pattern blocks (simulating terrain patches)
        ShimmerBox(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20,
        ),

        // Shimmering bottom card (Munro summary)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 70, left: 16, right: 16),
            child: ShimmerBox(
              width: double.infinity,
              height: 120,
              borderRadius: 20,
            ),
          ),
        ),
      ],
    );
  }
}
