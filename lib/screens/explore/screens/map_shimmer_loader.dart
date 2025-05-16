import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MapShimmerLoader extends StatelessWidget {
  const MapShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final shimmerBase = Colors.grey[300]!;
    final shimmerHighlight = Colors.grey[100]!;

    return Stack(
      children: [
        // Shimmering base "map" with pattern blocks (simulating terrain patches)
        Shimmer.fromColors(
          baseColor: shimmerBase,
          highlightColor: shimmerHighlight,
          child: GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 40,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
            ),
            itemBuilder: (_, i) {
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),

        // Simulated marker placeholders
        ...List.generate(8, (index) {
          final left = (index % 4) * 90.0 + 40;
          final top = (index ~/ 4) * 120.0 + 100;
          return Positioned(
            left: left,
            top: top,
            child: Shimmer.fromColors(
              baseColor: shimmerBase,
              highlightColor: shimmerHighlight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),

        // Shimmering bottom card (Munro summary)
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Shimmer.fromColors(
              baseColor: shimmerBase,
              highlightColor: shimmerHighlight,
              child: Container(
                height: 120,
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 120,
                      color: shimmerBase,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      height: 14,
                      width: 200,
                      color: shimmerBase,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Row(
                      children: List.generate(3, (i) {
                        return Container(
                          height: 12,
                          width: 40,
                          color: shimmerBase,
                          margin: const EdgeInsets.only(right: 8),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
