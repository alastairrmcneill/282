import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ActivityCard extends StatelessWidget {
  final PendingActivityReview review;
  const ActivityCard({super.key, required this.review});

  Future<void> _onSuccess(
    BuildContext context, {
    required StravaActivityReviewState stravaActivityReviewState,
    required bool selectMore,
  }) async {
    stravaActivityReviewState.startReviewing(review);
    final munroList = context.read<MunroState>().munroList;
    final confirmedMunroIds = review.matches
        .where((m) => stravaActivityReviewState.selectedMatchIds.contains(m.id))
        .map((m) => m.munroId)
        .toList();

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
    stravaActivityReviewState.finalizeReview(
      review: review,
      confirmedMatchIds: stravaActivityReviewState.selectedMatchIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroList = context.read<MunroState>().munroList;
    final formattedDate = DateFormat("EEE dd MMM").format(review.activity.startDate);
    final formattedDistance = ((review.activity.distanceM ?? 0) / 1000).toStringAsFixed(2);
    final formattedElevation = (review.activity.elevationGainM ?? 0).toInt().thousandsSeparator();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          final stravaActivityReviewState = context.read<StravaActivityReviewState>();
          _onSuccess(
            context,
            stravaActivityReviewState: stravaActivityReviewState,
            selectMore: false,
          );
        },
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.colors.stravaBackground,
                      ),
                      child: SvgPicture.asset('assets/icons/strava.svg'),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.activity.name, style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              '$formattedDate · ${formattedDistance}km · ${formattedElevation}m',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(PhosphorIconsRegular.caretRight, color: context.colors.middleGrey),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  children: review.matches.map((match) {
                    final munro = munroList.firstWhere((m) => m.id == match.munroId, orElse: () => Munro.empty);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: context.colors.accent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          munro.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Color(0xFF065F46)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: context.colors.middleGrey.withOpacity(0.05),
                  border: Border(top: BorderSide(width: 0.3, color: context.colors.textPrimary.withOpacity(0.2))),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: context.colors.stravaText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${review.matches.length} Munros to check',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
