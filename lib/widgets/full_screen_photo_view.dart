import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:two_eight_two/models/models.dart';

class FullScreenPhotoViewer extends StatefulWidget {
  final List<MunroPicture> initialPictures;
  final int initialIndex;
  final Future<List<MunroPicture>> Function() fetchMorePhotos;

  const FullScreenPhotoViewer({
    super.key,
    required this.initialPictures,
    required this.initialIndex,
    required this.fetchMorePhotos,
  });

  @override
  _FullScreenPhotoViewerState createState() => _FullScreenPhotoViewerState();
}

class _FullScreenPhotoViewerState extends State<FullScreenPhotoViewer> {
  late PageController _pageController;
  List<MunroPicture> photos = [];
  int currentIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    photos = widget.initialPictures;
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  Future<void> _loadMorePhotos() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      List<MunroPicture> newPhotos = await widget.fetchMorePhotos();

      setState(() {
        photos.addAll(newPhotos);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: photos.length,
            pageController: _pageController,
            onPageChanged: (index) async {
              setState(() {
                currentIndex = index;
              });
              if (index == photos.length - 1) {
                await _loadMorePhotos(); // Load more photos when the last one is reached
              }
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(photos[index].imageUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
