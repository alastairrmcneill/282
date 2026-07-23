import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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
  final Map<String, Post?> _postCache = {};
  Post? get _currentPost => currentIndex < photos.length ? _postCache[photos[currentIndex].postId] : null;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    photos = widget.args.initialPictures;
    currentIndex = widget.args.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
    _fetchPostForCurrentPhoto(currentIndex);
  }

  Future<void> _loadMorePhotos() async {
    if (!isLoading) {
      setState(() => isLoading = true);

      await widget.args.fetchMorePhotos();

      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchPostForCurrentPhoto(int index) async {
    if (index < photos.length) {
      final postId = photos[index].postId;
      if (!_postCache.containsKey(postId)) {
        try {
          final post = await context.read<PostsRepository>().readPostFromUid(uid: postId);
          if (mounted) setState(() => _postCache[postId] = post);
        } catch (error, stackTrace) {
          if (mounted) {
            context.read<Logger>().error(
              'Failed to fetch post for photo',
              error: error,
              stackTrace: stackTrace,
              context: {'postId': postId},
            );
          }
        }
      }
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
              setState(() => currentIndex = index);
              if (currentIndex + 1 < photos.length) await _fetchPostForCurrentPhoto(currentIndex + 1);
              if (index == photos.length - 1) await _loadMorePhotos();
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                tightMode: false,
                imageProvider: CachedNetworkImageProvider(
                  photos[index].imageUrl,
                ),
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
                    child: Icon(
                      PhosphorIconsRegular.warning,
                      color: Colors.white,
                    ),
                  );
                },
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
          ),
          if (_currentPost != null)
            ExpandablePhotoInfo(
              currentPost: _currentPost,
              expanded: _expanded,
              onMoreTapped: () => setState(() => _expanded = true),
              onDismissed: () => setState(() => _expanded = false),
            ),
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(PhosphorIconsBold.x, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          if (isLoading) LoadingWidget(size: 32),
        ],
      ),
    );
  }
}
