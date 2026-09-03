import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/found_on_strava/widgets/widgets.dart';

class FoundOnStravaScreen extends StatelessWidget {
  static const String route = '/found_on_strava';
  const FoundOnStravaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stravaActivityReviewState = context.watch<StravaActivityReviewState>();
    final hasPendingReviews = stravaActivityReviewState.pendingReviews.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Found on Strava"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: hasPendingReviews
            ? Column(
                children: [
                  const SizedBox(height: 16),
                  FoundOnStravaSubtitle(reviews: stravaActivityReviewState.pendingReviews),
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stravaActivityReviewState.pendingReviews.length,
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemBuilder: (context, index) {
                        final review = stravaActivityReviewState.pendingReviews[index];
                        return ActivityCard(review: review);
                      },
                    ),
                  ),
                  TextButton(
                    child: Text(
                      'None of these were munro days',
                      style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.solid,
                          color: context.colors.textMuted),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      stravaActivityReviewState.rejectReviews(
                        reviews: stravaActivityReviewState.pendingReviews,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              )
            : const FoundOnStravaEmptyState(),
      ),
    );
  }
}
