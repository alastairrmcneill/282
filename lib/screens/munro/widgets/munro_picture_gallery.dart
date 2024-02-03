import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/state/munro_detail_state.dart';

class MunroPictureGallery extends StatelessWidget {
  const MunroPictureGallery({super.key});
  @override
  Widget build(BuildContext context) {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context);
    List<String> imageURLs = munroDetailState.galleryPosts
        .expand((Post post) => post.imageURLs)
        .toList();
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 5, // gap between adjacent chips
        runSpacing: 5, // gap between lines
        children: imageURLs.map((url) {
          return Container(
            width: (MediaQuery.of(context).size.width - 10) / 3 - 5 * 2,
            height: (MediaQuery.of(context).size.width - 10) / 3 - 5 * 2,
            color: Colors.blue,
            child: Image.network(
              url,
              fit: BoxFit.cover,
            ),
          );
        }).toList(),
      ),
    );
  }
}
