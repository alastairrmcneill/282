import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MunroCard extends StatelessWidget {
  final Munro munro;
  const MunroCard({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    double width = MediaQuery.of(context).size.width - 60;

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15, top: 15),
      child: GestureDetector(
        onTap: () {
          munroState.setSelectedMunro = munro;
          MunroPictureService.getMunroPictures(context, munroId: munro.id, count: 4);
          ReviewService.getMunroReviews(context);
          Navigator.of(context).pushNamed(MunroScreen.route);
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
