import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class EmptyFeedHeaderImage extends StatelessWidget {
  const EmptyFeedHeaderImage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1757038822217-d68becfce696?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzY290dGlzaCUyMG1vdW50YWlucyUyMGZyaWVuZHNoaXAlMjBoaWtpbmd8ZW58MXx8fHwxNzcwODkyNjU0fDA&ixlib=rb-4.1.0&q=80&w=1080',
              fit: BoxFit.cover,
              color: Colors.white.withValues(alpha: 0.8),
              colorBlendMode: BlendMode.modulate,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.scaffoldBackgroundColor,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
