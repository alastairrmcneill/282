import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/nav/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaMatchesReviewBottomSheet extends StatelessWidget {
  final PendingActivityReview review;
  final VoidCallback onSubmit;
  const StravaMatchesReviewBottomSheet({
    super.key,
    required this.review,
    required this.onSubmit,
  });

  static Future<void> show(BuildContext context) async {
    final state = context.read<StravaActivityReviewState>();
    final review = state.pendingReviews.first;
    state.startReviewing(review);

    bool confirmed = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StravaMatchesReviewBottomSheet(
        review: review,
        onSubmit: () => confirmed = true,
      ),
    );

    if (!confirmed) {
      await state.finalizeReview(review: review, confirmedMatchIds: {});
    }
  }

  Future<void> _onSuccess(
    BuildContext context, {
    required StravaActivityReviewState stravaActivityReviewState,
    required bool selectMore,
  }) async {
    final munroList = context.read<MunroState>().munroList;
    final confirmedMunroIds = review.matches
        .where((m) => stravaActivityReviewState.selectedMatchIds.contains(m.id))
        .map((m) => m.munroId)
        .toList();

    stravaActivityReviewState.finalizeReview(
      review: review,
      confirmedMatchIds: stravaActivityReviewState.selectedMatchIds,
    );

    final createPostState = context.read<CreatePostState>();
    createPostState.reset();
    for (final munroId in confirmedMunroIds) {
      createPostState.addMunro(munroId);
    }

    final startDate = review.activity.startDate;
    createPostState.setCompletionDate = DateTime(startDate.year, startDate.month, startDate.day);
    createPostState.setCompletionStartTime = TimeOfDay.fromDateTime(review.activity.startDate);
    createPostState.setCompletionDuration =
        review.activity.durationS != null ? Duration(seconds: review.activity.durationS!.toInt()) : null;

    onSubmit();
    Navigator.of(context).pop();
    if (selectMore) {
      final mainMunro = munroList.firstWhere((m) => m.id == confirmedMunroIds.first);
      Navigator.of(context).pushNamed(
        SelectMunrosScreen.route,
        arguments: SelectMunrosScreenArgs(
          mainMunro: mainMunro,
        ),
      );
    } else {
      Navigator.of(context).pushNamed(CreatePostScreen.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stravaActivityReviewState = context.watch<StravaActivityReviewState>();
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
            StravaMatchesReviewBottomSheetHeader(activity: review.activity),
            const SizedBox(height: 8),
            StravaMatchesReviewBottomSheetTitle(review: review),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 20),
                children: review.matches.map((match) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: StravaReviewMunroTile(munroMatch: match),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            CtaButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(PhosphorIconsBold.check, size: 16),
                  const SizedBox(width: 10),
                  const Text('Add to my map'),
                ],
              ),
              onPressed: () async {
                await _onSuccess(
                  context,
                  stravaActivityReviewState: stravaActivityReviewState,
                  selectMore: false,
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text('Add one we missed', style: TextStyle(color: context.colors.textMuted)),
                  onPressed: () async {
                    _onSuccess(
                      context,
                      stravaActivityReviewState: stravaActivityReviewState,
                      selectMore: true,
                    );
                  },
                ),
                TextButton(
                  child: Text('Dismiss', style: TextStyle(color: context.colors.textMuted)),
                  onPressed: () {
                    stravaActivityReviewState.finalizeReview(
                      review: review,
                      confirmedMatchIds: {},
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
