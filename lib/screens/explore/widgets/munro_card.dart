import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroCard extends StatelessWidget {
  final Munro munro;
  const MunroCard({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 60;

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
        },
        child: Column(
          children: [
            MunroCardPicture(munro: munro, width: width),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MunroCardTitleText(munro: munro), MunroRatingText(munro: munro, showReviewCount: true)],
            ),
          ],
        ),
      ),
    );
  }
}
