import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSliverAppBar extends StatelessWidget {
  const MunroSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    Munro munro = munroState.selectedMunro!;

    return SliverAppBar(
      backgroundColor: MyColors.backgroundColor,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
          imageUrl: munro.pictureURL,
          fit: BoxFit.cover,
          placeholder: (context, url) => Image.asset(
            'assets/images/post_image_placeholder.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: 300,
          ),
          fadeInDuration: Duration.zero,
          errorWidget: (context, url, error) {
            return const Icon(Icons.photo_rounded);
          },
        ),
      ),
    );
  }
}
