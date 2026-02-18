import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/widgets/widgets.dart";

class PhotoGalleryRoutes {
  static const String munroGallery = '/munro/photo_gallery';
  static const String profileGallery = '/profile/photo_gallery';
}

class MunroPhotoGalleryArgs {
  final int munroId;
  final String munroName;
  MunroPhotoGalleryArgs({required this.munroId, required this.munroName});
}

class ProfilePhotoGalleryArgs {
  final String userId;
  final String displayName;
  ProfilePhotoGalleryArgs({required this.userId, required this.displayName});
}

class PhotoGalleryScreen extends StatefulWidget {
  final String title;

  const PhotoGalleryScreen({super.key, required this.title});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    final state = context.read<PhotoGalleryState<MunroPicture>>();
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (state.status != PhotoGalleryStatus.paginating) {
        state.paginate();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PhotoGalleryState<MunroPicture>>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: state.photos.length,
              itemBuilder: (BuildContext context, int index) {
                MunroPicture munroPicture = state.photos[index];
                return ClickableImage(
                  image: munroPicture,
                  munroPictures: state.photos,
                  initialIndex: index,
                  fetchMorePhotos: () async {
                    List<MunroPicture> newPhotos = await state.paginate();
                    return newPhotos;
                  },
                );
              },
            ),
          ),
          SizedBox(
            child: state.status == PhotoGalleryStatus.paginating ? const CircularProgressIndicator() : null,
          ),
        ],
      ),
    );
  }
}
