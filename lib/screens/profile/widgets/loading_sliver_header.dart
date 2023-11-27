import 'package:flutter/material.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LoadingSliverHeader extends StatefulWidget {
  const LoadingSliverHeader({super.key});

  @override
  State<LoadingSliverHeader> createState() => _LoadingSliverHeaderState();
}

class _LoadingSliverHeaderState extends State<LoadingSliverHeader> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the percentage of the AppBar's size as it collapses
          double percentage = (constraints.biggest.height - kToolbarHeight) / (180.0 - kToolbarHeight);
          // Ensure the percentage is between 0 and 1
          percentage = 1 - percentage.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: percentage,
              child: const ShimmerBox(
                width: 100,
                height: 24,
                borderRadius: 5,
              ),
            ),
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            centerTitle: false,
            background: const SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 15, top: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ShimmerBox(width: 80, height: 80, borderRadius: 80),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ShimmerBox(width: 30, height: 30, borderRadius: 5),
                              ShimmerBox(width: 30, height: 30, borderRadius: 5),
                              ShimmerBox(width: 30, height: 30, borderRadius: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ShimmerBox(width: 120, height: 24, borderRadius: 5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
