import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/models/munro_model.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';

class MunroCardPicture extends StatelessWidget {
  final Munro munro;
  final double width;
  const MunroCardPicture({super.key, required this.munro, required this.width});

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
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(12),
      ),
      child: SizedBox(
        width: width,
        height: width,
        child: Stack(
          children: [
            _isValidUrl(munro.pictureURL)
                ? CachedNetworkImage(
                    imageUrl: munro.pictureURL,
                    width: width,
                    height: width,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/post_image_placeholder.png',
                      fit: BoxFit.cover,
                      width: width,
                      height: width,
                    ),
                    fadeInDuration: Duration.zero,
                    errorWidget: (context, url, error) {
                      return Image.asset(
                        'assets/images/post_image_placeholder.png',
                        fit: BoxFit.cover,
                        width: width,
                        height: width,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/post_image_placeholder.png',
                    fit: BoxFit.cover,
                    width: width,
                    height: width,
                  ),
            Align(
              alignment: Alignment.topRight,
              child: MunroSaveButton(munro: munro),
            ),
          ],
        ),
      ),
    );
  }
}
