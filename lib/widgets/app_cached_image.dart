import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/logging/logging.dart';

class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  const AppCachedImage({super.key, required this.imageUrl});

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
    if (!_isValidUrl(imageUrl)) {
      return Image.asset(
        'assets/images/post_image_placeholder.png',
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: Duration.zero,
      placeholder: (context, url) => Image.asset(
        'assets/images/post_image_placeholder.png',
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) {
        context.read<Logger>().error(
              'Failed to load photo',
              error: error,
              context: {'imageUrl': url},
            );
        return Center(
          child: Icon(
            PhosphorIconsRegular.warning,
            size: 40,
            color: context.colors.divider,
          ),
        );
      },
    );
  }
}
