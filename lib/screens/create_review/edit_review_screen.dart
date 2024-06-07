import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:two_eight_two/models/models.dart";
import "package:two_eight_two/screens/create_review/state/create_review_state.dart";
import "package:two_eight_two/screens/create_review/widgets/widgets.dart";
import "package:two_eight_two/screens/notifiers.dart";
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
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
            return Scaffold(
              appBar: AppBar(),
            );
          default:
            return _buildScreen(context, createReviewState);
        }
      },
    );
  }

  Widget _buildScreen(BuildContext context, CreateReviewState createReviewState) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    Munro munro = munroState.munroList.firstWhere((element) => element.id == createReviewState.editingReview!.munroId);

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Review"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                munro.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
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
              const SizedBox(height: 5),
              TextFormFieldBase(
                initialValue: createReviewState.currentMunroReview,
                onSaved: (value) {
                  createReviewState.setCurrentMunroReview = value?.trim() ?? "";
                },
                maxLines: 5,
                hintText: "Comment",
              ),
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

                    if (createReviewState.status == CreateReviewStatus.initial) {
                      ReviewService.editReview(context);
                    }
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
