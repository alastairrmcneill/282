import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/screens/munro_photo_gallery_screen.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroPictureGallery extends StatelessWidget {
  const MunroPictureGallery({super.key});

  Widget _buildLoadingScreen(BuildContext context) {
    final boxSize = (MediaQuery.of(context).size.width - 60) / 4;

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runAlignment: WrapAlignment.start,
        spacing: 5,
        children: List.generate(
          4,
          (index) => ShimmerBox(
            borderRadius: 12,
            width: boxSize,
            height: boxSize,
          ),
        ),
      ),
    );
  }

  Widget _buildPictureRow(BuildContext context, MunroDetailState munroDetailState, MunroState munroState) {
    if (munroDetailState.munroPictures.isEmpty) {
      return const Center(
        child: Text("No pictures available"),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runAlignment: WrapAlignment.start,
        spacing: 5,
        children: munroDetailState.munroPictures.take(4).toList().asMap().entries.map((entry) {
          int index = entry.key;
          MunroPicture munroPicture = entry.value;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 4,
              height: (MediaQuery.of(context).size.width - 60) / 4,
              child: ClickableImage(
                image: munroPicture,
                munroPictures: munroDetailState.munroPictures,
                initialIndex: index,
                fetchMorePhotos: () async {
                  List<MunroPicture> newPhotos = await munroDetailState.paginateMunroPictures(
                    munroId: munroState.selectedMunro!.id,
                  );
                  return newPhotos;
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final munroDetailState = context.watch<MunroDetailState>();

    return Column(
      children: [
        InkWell(
          onTap: () {
            munroDetailState.loadMunroPictures(munroId: munroState.selectedMunro!.id);
            Navigator.of(context).pushNamed(MunroPhotoGallery.route);
          },
          child: Container(
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    "Photos",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Icon(
                  CupertinoIcons.forward,
                  size: 16,
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: (MediaQuery.of(context).size.width - 60) / 4,
          child: Consumer<MunroDetailState>(
            builder: (context, munroDetailState, child) {
              switch (munroDetailState.galleryStatus) {
                case MunroDetailStatus.loading:
                  return _buildLoadingScreen(context);
                case MunroDetailStatus.error:
                  return CenterText(text: munroDetailState.error.message);
                default:
                  return _buildPictureRow(context, munroDetailState, munroState);
              }
            },
          ),
        ),
      ],
    );
  }
}
