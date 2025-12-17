import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/widgets/widgets.dart";

class ProfilePhotoGalleryArgs {
  final String userId;
  final String displayName;
  ProfilePhotoGalleryArgs({required this.userId, required this.displayName});
}

class ProfilePhotoGallery extends StatefulWidget {
  final ProfilePhotoGalleryArgs args;
  static const String route = '/profile/photo_gallery';
  const ProfilePhotoGallery({super.key, required this.args});

  @override
  State<ProfilePhotoGallery> createState() => _ProfilePhotoGalleryState();
}

class _ProfilePhotoGalleryState extends State<ProfilePhotoGallery> {
  late ScrollController _scrollController;
  @override
  void initState() {
    final profileGalleryState = context.read<ProfileGalleryState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          profileGalleryState.status != ProfileGalleryStatus.paginating) {
        profileGalleryState.paginateMunroPictures(profileId: widget.args.userId);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileGalleryState = context.watch<ProfileGalleryState>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Photos from ${widget.args.displayName}"),
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
              itemCount: profileGalleryState.photos.length,
              itemBuilder: (BuildContext context, int index) {
                MunroPicture munroPicture = profileGalleryState.photos[index];
                return ClickableImage(
                  image: munroPicture,
                  munroPictures: profileGalleryState.photos,
                  initialIndex: index,
                  fetchMorePhotos: () async {
                    List<MunroPicture> newPhotos =
                        await profileGalleryState.paginateMunroPictures(profileId: widget.args.userId);
                    return newPhotos;
                  },
                );
              },
            ),
          ),
          SizedBox(
            child: profileGalleryState.status == ProfileGalleryStatus.paginating
                ? const CircularProgressIndicator()
                : null,
          ),
        ],
      ),
    );
  }
}
