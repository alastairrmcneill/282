import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/cached_munro_image.dart';

class MunroCard extends StatelessWidget {
  final Munro munro;
  const MunroCard({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
        },
        child: SizedBox(
          width: double.infinity,
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedMunroImage(imageUrl: munro.pictureURL),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.6, 0.7, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                bottom: 16,
                right: 16,
                child: MunroCardTitleText(munro: munro),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
