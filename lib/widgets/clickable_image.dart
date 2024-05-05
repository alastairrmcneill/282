import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ClickableImage extends StatelessWidget {
  final String imageURL;
  const ClickableImage({super.key, required this.imageURL});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onDoubleTap: () {},
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(imageURL),
                    scaleStateCycle: (scaleState) => PhotoViewScaleState.zoomedIn,
                    enableRotation: false,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.5,
                    tightMode: true,
                  ),
                ),
              ),
            );
          },
        );
      },
      child: CachedNetworkImage(
        progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
          child: LinearProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
        imageUrl: imageURL,
        fit: BoxFit.cover,
      ),
    );
  }
}
