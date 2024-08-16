import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/services/services.dart";
import "package:two_eight_two/widgets/widgets.dart";

class MunroPhotoGallery extends StatefulWidget {
  const MunroPhotoGallery({super.key});

  @override
  State<MunroPhotoGallery> createState() => _MunroPhotoGalleryState();
}

class _MunroPhotoGalleryState extends State<MunroPhotoGallery> {
  late ScrollController _scrollController;
  @override
  void initState() {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          munroDetailState.galleryStatus != MunroDetailStatus.paginating) {
        MunroPictureService.paginateMunroPictures(context, munroId: munroState.selectedMunro!.id);
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
    MunroState munroState = Provider.of<MunroState>(context);
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Photos from ${munroState.selectedMunro?.name}"),
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
              itemCount: munroDetailState.munroPictures.length,
              itemBuilder: (BuildContext context, int index) {
                MunroPicture munroPicture = munroDetailState.munroPictures[index];
                return ClickableImage(
                  image: munroPicture,
                  munroPictures: munroDetailState.munroPictures,
                  initialIndex: index,
                  fetchMorePhotos: () async {
                    List<MunroPicture> newPhotos =
                        await MunroPictureService.paginateMunroPictures(context, munroId: munroState.selectedMunro!.id);
                    return newPhotos;
                  },
                );
              },
            ),
          ),
          SizedBox(
            child: munroDetailState.galleryStatus == MunroDetailStatus.paginating
                ? const CircularProgressIndicator()
                : null,
          ),
        ],
      ),
    );
  }
}
