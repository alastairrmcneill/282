import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroDetailsScroll extends StatelessWidget {
  final Munro munro;
  const MunroDetailsScroll({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MunroDescriptionScroll(),
        const PaddedDivider(top: 15, bottom: 5),
        const MunroDirectionsWidget(),
        const PaddedDivider(top: 5, bottom: 20),
        const MunroPictureGallery(),
        const PaddedDivider(),
        MunroWeatherWidget(munro: munro),
        const PaddedDivider(),
        MunroReviewsWidgetScroll(),
        const SizedBox(height: 80),
      ],
    );
  }
}
