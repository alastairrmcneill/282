import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_review/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateReviewsScreen extends StatelessWidget {
  CreateReviewsScreen({super.key});
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const String route = '/review/create';

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
              AchievementsState achievementsState = Provider.of<AchievementsState>(context, listen: false);
              if (achievementsState.recentlyCompletedAchievements.isNotEmpty) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AchievementsCompletedScreen.route, // The name of the route you want to navigate to
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
            });
            return const SizedBox();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, CreateReviewState createReviewState) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => createReviewState.setStatus = CreateReviewStatus.loaded,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("How was your hike?"),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...createReviewState.munrosToReview.map((Munro munro) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            munro.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 5),
                          StarRatingFormField(
                            initialValue: createReviewState.reviews[munro.id]!["rating"],
                            validator: (rating) {
                              if (rating == null || rating < 1) {
                                return 'Please select at least one star';
                              }
                              return null;
                            },
                            onSaved: (newValue) => createReviewState.setMunroRating(munro.id, newValue!),
                          ),
                          const SizedBox(height: 5),
                          TextFormFieldBase(
                            initialValue: createReviewState.reviews[munro.id]!["review"],
                            onSaved: (value) {
                              createReviewState.setMunroReview(munro.id, value?.trim() ?? "");
                            },
                            maxLines: 5,
                            hintText: "Comment",
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        _formKey.currentState!.save();

                        ReviewService.createReview(context);
                      },
                      child: const Text("Submit"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
