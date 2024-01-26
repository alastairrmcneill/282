import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/state/munro_detail_state.dart';

class MunroPictureGallery extends StatelessWidget {
  const MunroPictureGallery({super.key});

  @override
  Widget build(BuildContext context) {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context);
    print(munroDetailState.galleryStatus);
    print(munroDetailState.galleryPosts.length);
    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.red,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: munroDetailState.galleryPosts
            .expand((Post post) => post.imageURLs)
            .toList()
            .length,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.blue,
          );
        },
      ),
    );
  }
}
