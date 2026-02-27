import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
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

  Widget _buildPictureRow(BuildContext context, MunroDetailState munroDetailState) {
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
        children: munroDetailState.munroPictures.take(4).map((munroPicture) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 4,
              height: (MediaQuery.of(context).size.width - 60) / 4,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    PhotoGalleryRoutes.munroGallery,
                    arguments: MunroPhotoGalleryArgs(
                      munroId: munroDetailState.selectedMunro!.id,
                      munroName: munroDetailState.selectedMunro!.name,
                    ),
                  );
                },
                child: CachedNetworkImage(
                  progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                    child: LinearProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                  imageUrl: munroPicture.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error),
                          Text(
                            error.toString().contains('ClientException with SocketException: Connection reset by peer')
                                ? "Error loading image. Please check your internet connection and try again."
                                : error.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.watch<MunroDetailState>();

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(
              PhotoGalleryRoutes.munroGallery,
              arguments: MunroPhotoGalleryArgs(
                munroId: munroDetailState.selectedMunro!.id,
                munroName: munroDetailState.selectedMunro!.name,
              ),
            );
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
              switch (munroDetailState.status) {
                case MunroDetailStatus.loading:
                  return _buildLoadingScreen(context);
                case MunroDetailStatus.error:
                  return CenterText(text: munroDetailState.error.message);
                default:
                  return _buildPictureRow(context, munroDetailState);
              }
            },
          ),
        ),
      ],
    );
  }
}
