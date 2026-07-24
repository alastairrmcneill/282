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
        Navigator.of(context).pushNamed(
          FullScreenPhotoViewer.route,
          arguments: FullScreenPhotoViewerArgs(
            initialPictures: munroPictures,
            initialIndex: initialIndex,
            fetchMorePhotos: () async {
              List<MunroPicture> newPhotos = await fetchMorePhotos();
              return newPhotos;
            },
          ),
        );
      },
      child: AppCachedImage(imageUrl: image.imageUrl),
    );
  }
}
