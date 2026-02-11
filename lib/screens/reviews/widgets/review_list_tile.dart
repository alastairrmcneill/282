import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/datetime_extension.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/star_rating_row.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewListTile extends StatelessWidget {
  final Review review;
  const ReviewListTile({super.key, required this.review});

  void _showActionsDialog(BuildContext context) {
    final userState = context.read<UserState>();
    final createReviewState = context.read<CreateReviewState>();
    final isOwner = review.authorId == userState.currentUser?.uid;

    if (Platform.isIOS) {
      _showIOSActionSheet(context, isOwner, createReviewState);
    } else {
      _showAndroidBottomSheet(context, isOwner, createReviewState);
    }
  }

  void _showIOSActionSheet(BuildContext context, bool isOwner, CreateReviewState createReviewState) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: isOwner
            ? [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    createReviewState.reset();
                    createReviewState.loadReview = review;
                    Navigator.of(context).pushNamed(EditReviewScreen.route);
                  },
                  child: const Text('Edit'),
                ),
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<ReviewsState>().deleteReview(review: review);
                  },
                  isDestructiveAction: true,
                  child: const Text('Delete'),
                ),
              ]
            : [
                CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.pop(context);
                    final reportState = context.read<ReportState>();
                    reportState.setContentId = review.uid ?? "";
                    reportState.setType = "review";
                    Navigator.of(context).pushNamed(ReportScreen.route);
                  },
                  child: const Text('Report'),
                ),
              ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAndroidBottomSheet(BuildContext context, bool isOwner, CreateReviewState createReviewState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isOwner
              ? [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      createReviewState.reset();
                      createReviewState.loadReview = review;
                      Navigator.of(context).pushNamed(EditReviewScreen.route);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<ReviewsState>().deleteReview(review: review);
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: const Icon(Icons.flag),
                    title: const Text('Report'),
                    onTap: () {
                      Navigator.pop(context);
                      final reportState = context.read<ReportState>();
                      reportState.setContentId = review.uid ?? "";
                      reportState.setType = "review";
                      Navigator.of(context).pushNamed(ReportScreen.route);
                    },
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () => _showActionsDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircularProfilePicture(
              radius: 15,
              profilePictureURL: review.authorProfilePictureURL,
              profileUid: review.authorId,
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.authorDisplayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          review.dateTime.timeAgoShort(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    StarRatingRow(rating: review.rating),
                    const SizedBox(height: 8),
                    Text(
                      review.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MyColors.mutedText, height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
