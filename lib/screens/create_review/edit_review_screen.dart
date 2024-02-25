import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/screens/create_review/state/create_review_state.dart";
import "package:two_eight_two/screens/create_review/widgets/widgets.dart";
import "package:two_eight_two/services/services.dart";
import "package:two_eight_two/widgets/widgets.dart";

class EditReviewScreen extends StatelessWidget {
  const EditReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateReviewState>(
      builder: (context, createReviewState, child) {
        switch (createReviewState.status) {
          case CreateReviewStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: Column(
                children: [
                  CenterText(text: createReviewState.error.message),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Exit"),
                  ),
                ],
              ),
            );
          case CreateReviewStatus.loaded:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pop(context);
            });
            return const SizedBox();
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, CreateReviewState createReviewState) {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Write a review"),
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
                if (!_formKey.currentState!.validate()) {
                  return;
                }
                _formKey.currentState!.save();

                if (createReviewState.status == CreateReviewStatus.initial) {
                  ReviewService.editReview(context);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
