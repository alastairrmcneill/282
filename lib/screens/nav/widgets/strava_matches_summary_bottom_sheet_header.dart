import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaMatchesSummaryBottomSheetHeader extends StatelessWidget {
  const StravaMatchesSummaryBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: context.colors.stravaBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/icons/strava.svg', width: 16, height: 16),
          const SizedBox(width: 8),
          Text(
            'WHILE YOU WERE AWAY',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: context.colors.stravaText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
