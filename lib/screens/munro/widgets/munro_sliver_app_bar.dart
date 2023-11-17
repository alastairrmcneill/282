import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroSliverAppBar extends StatefulWidget {
  const MunroSliverAppBar({super.key});

  @override
  State<MunroSliverAppBar> createState() => _MunroScreenSliverAppBarState();
}

class _MunroScreenSliverAppBarState extends State<MunroSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return SliverAppBar(
      expandedHeight: 255.0,
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the percentage of the AppBar's size as it collapses
          double percentage = (constraints.biggest.height - kToolbarHeight) / (255.0 - kToolbarHeight);
          // Ensure the percentage is between 0 and 1
          percentage = 1 - percentage.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: percentage,
              child: Text(munroState.selectedMunro?.name ?? "Munro"),
            ),
            centerTitle: false,
            background: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: munroState.selectedMunro?.pictureURL ?? "",
                      fit: BoxFit.fitWidth,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                        child: LinearProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.photo_rounded);
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        munroState.selectedMunro?.name ?? "Munro",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
