import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/loading_widget.dart';

class FullScreenPhotoViewerArgs {
  final List<MunroPicture> initialPictures;
  final int initialIndex;
  final Future<List<MunroPicture>> Function() fetchMorePhotos;

  FullScreenPhotoViewerArgs({
    required this.initialPictures,
    required this.initialIndex,
    required this.fetchMorePhotos,
  });
}

class FullScreenPhotoViewer extends StatefulWidget {
  static const String route = "/fullScreenPhotoViewer";
  final FullScreenPhotoViewerArgs args;

  const FullScreenPhotoViewer({super.key, required this.args});

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
    photos = widget.args.initialPictures;
    currentIndex = widget.args.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  Future<void> _loadMorePhotos() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      await widget.args.fetchMorePhotos();

      setState(() {
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
                errorBuilder: (context, error, stackTrace) {
                  context.read<Logger>().error(
                        'Failed to load photo',
                        error: error,
                        stackTrace: stackTrace,
                        context: {'imageUrl': photos[index].imageUrl},
                      );
                  return const Center(
                    child: Icon(Icons.error, color: Colors.white),
                  );
                },
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
            LoadingWidget(
              text: "Loading more photos...",
              size: 32,
            ),
        ],
      ),
    );
  }
}
