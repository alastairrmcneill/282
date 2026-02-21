import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class StarRatingRow extends StatelessWidget {
  final int rating;
  const StarRatingRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => SizedBox(
          width: 17,
          height: 20,
          child: Icon(
            Icons.star_rounded,
            color: index < rating ? MyColors.starColor : MyColors.lightGrey,
            size: 20,
          ),
        ),
      ),
    );
  }
}
