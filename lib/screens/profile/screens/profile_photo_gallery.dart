import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/services/services.dart";
import "package:two_eight_two/widgets/widgets.dart";

class ProfilePhotoGallery extends StatefulWidget {
  const ProfilePhotoGallery({super.key});

  @override
  State<ProfilePhotoGallery> createState() => _ProfilePhotoGalleryState();
}

class _ProfilePhotoGalleryState extends State<ProfilePhotoGallery> {
  late ScrollController _scrollController;
  @override
  void initState() {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          profileState.photoStatus != ProfilePhotoStatus.paginating) {
        MunroPictureService.paginateProfilePictures(context, profileId: profileState.user?.uid ?? '');
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
    ProfileState profileState = Provider.of<ProfileState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Photos from ${profileState.user?.displayName ?? "user"}"),
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
              itemCount: profileState.profilePhotos.length,
              itemBuilder: (BuildContext context, int index) {
                MunroPicture munroPicture = profileState.profilePhotos[index];
                return ClickableImage(
                  imageURL: munroPicture.imageUrl,
                );
              },
            ),
          ),
          SizedBox(
            child: profileState.photoStatus == ProfilePhotoStatus.paginating ? const CircularProgressIndicator() : null,
          ),
        ],
      ),
    );
  }
}
