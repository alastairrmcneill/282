import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/models/munro_model.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/widgets/app_cached_image.dart';

class MunroCardPicture extends StatelessWidget {
  final Munro munro;
  final double width;
  const MunroCardPicture({super.key, required this.munro, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(
        Radius.circular(12),
      ),
      child: SizedBox(
        width: width,
        height: width,
        child: Stack(
          children: [
            AppCachedImage(imageUrl: munro.pictureURL),
            Align(
              alignment: Alignment.topRight,
              child: MunroSaveButton(munro: munro),
            ),
          ],
        ),
      ),
    );
  }
}
