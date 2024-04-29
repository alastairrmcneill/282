import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/screens/munro_photo_gallery_screen.dart';
import 'package:two_eight_two/screens/munro/state/munro_detail_state.dart';
import 'package:two_eight_two/widgets/clickable_image.dart';

class MunroPictureGallery extends StatelessWidget {
  const MunroPictureGallery({super.key});
  @override
  Widget build(BuildContext context) {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context);
    print("MunroDetailState: ${munroDetailState.galleryPosts.length}");
    List<String> imageURLs = munroDetailState.galleryPosts
        .expand((Post post) => post.imageUrlsMap.values.expand((element) => element).toList())
        .toList();

    if (imageURLs.isEmpty) {
      return const Center(
        child: Text("No picutres available"),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Wrap(
            spacing: 5, // gap between adjacent chips
            runSpacing: 5, // gap between lines
            children: imageURLs.take(9).map((url) {
              return Container(
                width: (MediaQuery.of(context).size.width - 10) / 3 - 5 * 2,
                height: (MediaQuery.of(context).size.width - 10) / 3 - 5 * 2,
                color: Colors.blue,
                child: ClickableImage(imageURL: url),
              );
            }).toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MunroPhotoGallery()),
                );
              },
              child: const Text("View All Photos"),
            ),
          )
        ],
      ),
    );
  }
}
