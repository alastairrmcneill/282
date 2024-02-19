import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/create_review/state/create_review_state.dart';
import 'package:two_eight_two/screens/create_review/widgets/widgets.dart';

class CreateReviewScreen extends StatefulWidget {
  const CreateReviewScreen({super.key});

  @override
  State<CreateReviewScreen> createState() => _CreateReviewScreenState();
}

class _CreateReviewScreenState extends State<CreateReviewScreen> {
  late PageController _pageController;

  @override
  void initState() {
    CreateReviewState createReviewState = Provider.of<CreateReviewState>(context, listen: false);
    super.initState();

    _pageController = PageController()
      ..addListener(() {
        setState(() {
          createReviewState.setCurrentIndex = _pageController.page!.round();
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
              return CreateReviewPage(
                pageController: _pageController,
              );
            },
          ),
        ),
      ),
    );
  }
}
