import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroRatingText extends StatelessWidget {
  final Munro munro;
  final bool showReviewCount;
  const MunroRatingText({super.key, required this.munro, required this.showReviewCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      textBaseline: TextBaseline.alphabetic,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      children: [
        Text(
          munro.averageRating?.toStringAsFixed(1) ?? "0",
        ),
        const SizedBox(width: 2),
        const Icon(
          CupertinoIcons.star_fill,
          size: 12,
          color: Colors.amber,
        ),
        showReviewCount ? const SizedBox(width: 5) : const SizedBox(),
        showReviewCount
            ? Text(
                '(${munro.reviewCount ?? 0})',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
              )
            : const SizedBox(),
      ],
    );
  }
}
