import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

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
            color: index < rating ? context.colors.starColor : context.colors.border,
            size: 20,
          ),
        ),
      ),
    );
  }
}
