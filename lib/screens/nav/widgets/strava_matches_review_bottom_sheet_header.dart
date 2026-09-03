import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class StravaMatchesReviewBottomSheetHeader extends StatelessWidget {
  final StravaActivity activity;
  const StravaMatchesReviewBottomSheetHeader({super.key, required this.activity});

  String getActivityDistance(double distanceM) {
    if (distanceM < 1000) {
      return "${distanceM.toStringAsFixed(0)} m";
    } else {
      return "${(distanceM / 1000).toStringAsFixed(1)} km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/icons/strava.svg', width: 20, height: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "${activity.name} · ${getActivityDistance(activity.distanceM!)} · ${activity.elevationGainM!.toInt().thousandsSeparator()}m",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );
  }
}
