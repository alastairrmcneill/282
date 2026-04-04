import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroHeroImage extends StatelessWidget {
  final Munro munro;
  const MunroHeroImage({super.key, required this.munro});

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isValidUrl(munro.pictureURL)
        ? CachedNetworkImage(
            imageUrl: munro.pictureURL,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              'assets/images/post_image_placeholder.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: 300,
            ),
            fadeInDuration: Duration.zero,
            errorWidget: (context, url, error) {
              return Image.asset(
                'assets/images/post_image_placeholder.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                height: 300,
              );
            },
          )
        : Image.asset(
            'assets/images/post_image_placeholder.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: 300,
          );
  }
}
