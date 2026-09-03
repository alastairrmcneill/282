import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/nav/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaMatchesSummaryBottomSheet extends StatelessWidget {
  final List<PendingActivityReview> reviews;
  final VoidCallback onSubmit;
  const StravaMatchesSummaryBottomSheet({
    super.key,
    required this.reviews,
    required this.onSubmit,
  });

  static Future<void> show(BuildContext context) async {
    final state = context.read<StravaActivityReviewState>();
    bool confirmed = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StravaMatchesSummaryBottomSheet(
        reviews: state.pendingReviews,
        onSubmit: () => confirmed = true,
      ),
    );

    if (!confirmed) {
      await state.rejectReviews(reviews: state.pendingReviews);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stravaActivityReviewState = context.read<StravaActivityReviewState>();
    final pendingReviews = stravaActivityReviewState.pendingReviews;
    final munroCount = pendingReviews.fold<int>(0, (sum, r) => sum + r.matches.length);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetDragHandle(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StravaMatchesSummaryBottomSheetHeader(),
            ),
            const SizedBox(height: 16),
            StravaMatchesSummaryBottomSheetTitle(reviews: stravaActivityReviewState.pendingReviews),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                onSubmit();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(FoundOnStravaScreen.route);
              },
              child: Row(
                children: [
                  Expanded(
                    child: StravaMatchesSummaryStatCard(
                      value: '${pendingReviews.length}',
                      label: 'walks to check',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StravaMatchesSummaryStatCard(
                      value: '$munroCount',
                      label: 'Munros found',
                      accent: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CtaButton(
              child: Text('Review them >'),
              onPressed: () {
                onSubmit();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(FoundOnStravaScreen.route);
              },
            ),
            TextButton(
              child: Text('Dismiss', style: TextStyle(color: context.colors.textMuted)),
              onPressed: () {
                Navigator.of(context).pop();
                stravaActivityReviewState.rejectReviews(
                  reviews: stravaActivityReviewState.pendingReviews,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
