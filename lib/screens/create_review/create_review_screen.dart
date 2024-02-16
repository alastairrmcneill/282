import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_review/state/create_review_state.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  late PageController _pageController;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _currentPage = _pageController.page!.round() + 1;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: createReviewState.munrosToReview.length,
            itemBuilder: (context, index) {
              Munro munro = createReviewState.munrosToReview[index];
              return Container(
                child: Center(
                  child: Column(
                    children: [
                      Text("Write a review"),
                      Text("${munro.name} - $_currentPage/${createReviewState.munrosToReview.length}"),
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

                          if (index < createReviewState.munrosToReview.length - 1) {
                            _pageController.nextPage(
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
                        },
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
