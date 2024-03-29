import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/create_review/widgets/widgets.dart";
import "package:two_eight_two/screens/notifiers.dart";
import "package:two_eight_two/screens/screens.dart";
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
                        HomeScreen.route, // The name of the route you want to navigate to
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
                AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
                print("recentlyCompletedAchievements: ${achievementsState.recentlyCompletedAchievements.length}");
                if (achievementsState.recentlyCompletedAchievements.isNotEmpty) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AchievementsScreen.route, // The name of the route you want to navigate to
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                  );
                } else {
                  // Navigate back to where you were when it was called?
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.route, // The name of the route you want to navigate to
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                  );
                }
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
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Write a review"),
          Text("${munro.name} - ${createReviewState.currentIndex + 1}/${createReviewState.munrosToReview.length}"),
          StarRatingFormField(
            initialValue: createReviewState.currentMunroRating,
            validator: (rating) {
              if (rating == null || rating < 1) {
                return 'Please select at least one star';
              }
              return null;
            },
            onSaved: (newValue) => createReviewState.setCurrentMunroRating = newValue!,
          ),
          TextFormField(
            initialValue: createReviewState.currentMunroReview,
            onSaved: (value) {
              createReviewState.setCurrentMunroReview = value?.trim() ?? "";
            },

            maxLines: 5,
            textAlignVertical: TextAlignVertical.top, // Add this line
            decoration:
                const InputDecoration(hintText: "Write a review (optional)", contentPadding: EdgeInsets.all(10)),
          ),
          ElevatedButton(
              onPressed: () {
                AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
                print("recentlyCompletedAchievements: ${achievementsState.recentlyCompletedAchievements.length}");
                if (achievementsState.recentlyCompletedAchievements.isNotEmpty) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AchievementsScreen.route, // The name of the route you want to navigate to
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                  );
                } else {
                  // Navigate back to where you were when it was called?
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    HomeScreen.route, // The name of the route you want to navigate to
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
                  );
                }
              },
              child: Text("Skip")),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              _formKey.currentState!.save();

              if (createReviewState.status == CreateReviewStatus.initial) {
                ReviewService.createReview(context);
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
