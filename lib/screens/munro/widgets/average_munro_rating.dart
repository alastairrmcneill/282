import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class AverageMunroRating extends StatelessWidget {
  const AverageMunroRating({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: Column(
        children: [
          Text("${munroState.selectedMunro?.averageRating ?? 0}"),
          RatingBar(
            itemSize: 30,
            ratingWidget: RatingWidget(
              full: const Icon(Icons.star, color: Colors.amber),
              half: const Icon(Icons.star_half, color: Colors.amber),
              empty: const Icon(Icons.star_border, color: Colors.amber),
            ),
            onRatingUpdate: (rating) {},
            initialRating: munroState.selectedMunro?.averageRating ?? 0.0,
            allowHalfRating: true,
            ignoreGestures: true,
          ),
          Text("(${munroState.selectedMunro?.reviewCount ?? 0})")
        ],
      ),
    );
  }
}
