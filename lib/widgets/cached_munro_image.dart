import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedMunroImage extends StatelessWidget {
  final String imageUrl;
  const CachedMunroImage({super.key, required this.imageUrl});
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isValidUrl(imageUrl)
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Image.asset(
              'assets/images/post_image_placeholder.png',
              fit: BoxFit.cover,
            ),
            errorWidget: (context, url, error) => Image.asset(
              'assets/images/post_image_placeholder.png',
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'assets/images/post_image_placeholder.png',
            fit: BoxFit.cover,
          );
  }
}
