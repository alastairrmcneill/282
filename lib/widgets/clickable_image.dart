import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ClickableImage extends StatelessWidget {
  final List<MunroPicture> munroPictures;
  final int initialIndex;
  final Future<List<MunroPicture>> Function() fetchMorePhotos;
  final MunroPicture image;
  const ClickableImage({
    super.key,
    required this.munroPictures,
    required this.initialIndex,
    required this.fetchMorePhotos,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenPhotoViewer(
              initialPictures: munroPictures,
              initialIndex: initialIndex,
              fetchMorePhotos: () async {
                List<MunroPicture> newPhotos = await fetchMorePhotos();
                return newPhotos;
              },
            ),
          ),
        );
      },
      child: CachedNetworkImage(
        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
          child: LinearProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
        imageUrl: image.imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }
}
