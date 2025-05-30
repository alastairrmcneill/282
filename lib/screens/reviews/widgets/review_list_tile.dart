import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/extensions/datetime_extension.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewListTile extends StatelessWidget {
  final Review review;
  const ReviewListTile({super.key, required this.review});

  Widget _buildPopUpMenu(
    BuildContext context, {
    required Review review,
    required UserState userState,
    required CreateReviewState createReviewState,
  }) {
    List<MenuItem> menuItems = [];
    if (review.authorId == userState.currentUser?.uid) {
      menuItems = [
        MenuItem(
          text: 'Edit',
          onTap: () {
            createReviewState.reset();
            createReviewState.loadReview = review;
            Navigator.of(context).pushNamed(EditReviewScreen.route);
          },
        ),
        MenuItem(
          text: 'Delete',
          onTap: () {
            ReviewService.deleteReview(context, review: review);
          },
        ),
      ];
    } else {
      ReportState reportState = Provider.of<ReportState>(context, listen: false);
      menuItems = [
        MenuItem(
          text: 'Report',
          onTap: () {
            reportState.setContentId = review.uid ?? "";
            reportState.setType = "review";
            Navigator.of(context).pushNamed(ReportScreen.route);
          },
        ),
      ];
    }
    return PopupMenuBase(items: menuItems);
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularProfilePicture(
            radius: 15,
            profilePictureURL: review.authorProfilePictureURL,
            profileUid: review.authorId,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    ProfileService.loadUserFromUid(context, userId: review.authorId);
                    Navigator.of(context).pushNamed(ProfileScreen.route);
                  },
                  child: Text(
                    "${review.authorDisplayName} - ${review.dateTime.timeAgoShort()}",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(height: 1.2),
                  ),
                ),
                const SizedBox(height: 5),
                RatingBar(
                  initialRating: review.rating.toDouble(),
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {},
                  ratingWidget: RatingWidget(
                    full: const Icon(CupertinoIcons.star_fill, color: Colors.amber),
                    half: const Icon(CupertinoIcons.star_fill, color: Colors.amber),
                    empty: Icon(CupertinoIcons.star_fill, color: Colors.grey[200]),
                  ),
                  itemSize: 20,
                  allowHalfRating: false,
                ),
                Text(
                  review.text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _buildPopUpMenu(
            context,
            review: review,
            userState: userState,
            createReviewState: createReviewState,
          ),
        ],
      ),
    );
  }
}
