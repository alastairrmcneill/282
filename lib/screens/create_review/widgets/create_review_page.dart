import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/create_review/state/create_review_state.dart";
import "package:two_eight_two/services/services.dart";
import "package:two_eight_two/widgets/widgets.dart";

class CreateReviewPage extends StatelessWidget {
  final PageController pageController;
  const CreateReviewPage({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateReviewState>(
      builder: (context, createReviewState, child) {
        switch (createReviewState.status) {
          case CreateReviewStatus.error:
            return SafeArea(
              child: Column(
                children: [
                  CenterText(text: createReviewState.error.message),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        "/home_screen", // The name of the route you want to navigate to
                        (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                      );
                    },
                    child: const Text("Exit"),
                  ),
                ],
              ),
            );
          case CreateReviewStatus.loaded:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (createReviewState.currentIndex < createReviewState.munrosToReview.length - 1) {
                createReviewState.setStatus = CreateReviewStatus.initial;
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/home_screen", // The name of the route you want to navigate to
                  (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                );
              }
            });
            return const SizedBox();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, CreateReviewState createReviewState) {
    Munro munro = createReviewState.munrosToReview[createReviewState.currentIndex];
    return Container(
      child: Center(
        child: Column(
          children: [
            Text("Write a review"),
            Text("${munro.name} - ${createReviewState.currentIndex + 1}/${createReviewState.munrosToReview.length}"),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/home_screen", // The name of the route you want to navigate to
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                  );
                },
                child: Text("Skip")),
            ElevatedButton(
              onPressed: () {
                // Check if user has done a review
                // If they have send to database
                // Once done then move to next page or home
                createReviewState.setCurrentMunroRating = 2;
                createReviewState.setCurrentMunroReview = "This is a review";

                ReviewService.createReview(context);
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
