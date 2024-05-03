import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_review/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreateReviewsScreen extends StatelessWidget {
  CreateReviewsScreen({super.key});
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            });
            return const SizedBox();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, CreateReviewState createReviewState) {
    print('Building screen');
    print('State: ${createReviewState.status}');
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.multiply),
            onPressed: () => createReviewState.setStatus = CreateReviewStatus.loaded,
          ),
          title: const Text("Review Munros"),
          actions: [
            IconButton(
              icon: Icon(FontAwesomeIcons.check),
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();

                ReviewService.createReview(context);
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: createReviewState.munrosToReview.map((Munro munro) {
                return Column(
                  children: [
                    CenterText(text: munro.name),
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
                    RepaintBoundary(
                      child: TextFormField(
                        initialValue: createReviewState.reviews[munro.id]!["review"],
                        onSaved: (value) {
                          createReviewState.setMunroReview(munro.id, value?.trim() ?? "");
                        },
                        maxLines: 5,
                        textAlignVertical: TextAlignVertical.top, // Add this line
                        decoration: const InputDecoration(
                          hintText: "Write a review (optional)",
                          contentPadding: EdgeInsets.all(10),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
