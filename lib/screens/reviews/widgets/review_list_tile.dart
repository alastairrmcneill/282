import 'package:flutter/material.dart';
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
    if (review.authorId == userState.currentUser?.uid) {
      return PopupMenuButton(
        icon: Icon(Icons.more_vert_rounded),
        onSelected: (value) async {
          if (value == MenuItems.item1) {
            // Edit
            createReviewState.reset();
            createReviewState.loadReview = review;
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditReviewScreen()));
          } else if (value == MenuItems.item2) {
            // Delete
            ReviewService.deleteReview(context, review: review);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: MenuItems.item1,
            child: Text('Edit'),
          ),
          PopupMenuItem(
            value: MenuItems.item2,
            child: Text('Delete'),
          ),
        ],
      );
    } else {
      return const SizedBox(width: 48);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircularProfilePicture(
            radius: 20,
            profilePictureURL: review.authorProfilePictureURL,
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${review.authorDisplayName} - ${review.dateTime.timeAgoShort()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const SizedBox(height: 10),
                RatingBar(
                  initialRating: review.rating.toDouble(),
                  ignoreGestures: true,
                  onRatingUpdate: (rating) {},
                  ratingWidget: RatingWidget(
                    full: const Icon(Icons.star, color: Colors.amber),
                    half: const Icon(Icons.star_half, color: Colors.amber),
                    empty: const Icon(Icons.star_border, color: Colors.amber),
                  ),
                  itemSize: 20,
                  allowHalfRating: false,
                ),
                Text(review.text),
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
