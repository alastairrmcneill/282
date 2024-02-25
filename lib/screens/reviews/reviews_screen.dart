import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    ReviewsState reviewsState = Provider.of<ReviewsState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          reviewsState.status != ReviewsStatus.paginating) {
        if (reviewsState.source == ReviewsSource.munro) {
          ReviewService.paginateMunroReviews(context);
        } else {
          ReviewService.paginateProfileReviews(context);
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (context, reviewsState, child) {
        switch (reviewsState.status) {
          case ReviewsStatus.loading:
            return _buildLoadingScreen(context, reviewsState);

          case ReviewsStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: reviewsState.error.message),
            );
          default:
            return _buildScreen(context, reviewsState);
        }
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context, ReviewsState reviewsState) {
    return Scaffold(
      appBar: AppBar(),
      body: const LoadingWidget(),
    );
  }

  Widget _buildScreen(BuildContext context, ReviewsState reviewsState) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reviewsState.source == ReviewsSource.munro ? 'Munro Reviews' : 'Profile Reviews'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: reviewsState.reviews.length,
        itemBuilder: (BuildContext context, int index) {
          return ReviewListTile(review: reviewsState.reviews[index]);
        },
      ),
    );
  }
}
