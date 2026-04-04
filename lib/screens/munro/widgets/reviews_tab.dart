import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewsTab extends StatefulWidget {
  final int munroId;
  final ScrollController scrollController;
  const ReviewsTab({super.key, required this.munroId, required this.scrollController});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final reviewsState = context.read<ReviewsState>();
    if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 300 &&
        reviewsState.status == ReviewsStatus.loaded) {
      reviewsState.paginateMunroReviews(widget.munroId);
    }
  }

  Widget _buildLoadingScreen() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      itemCount: 3,
      itemBuilder: (context, index) {
        return ShimmerBox(width: double.infinity, height: 100, borderRadius: 12);
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16),
    );
  }

  Widget _buildScreen(BuildContext context, ReviewsState reviewsState) {
    return Column(
      children: [
        const SizedBox(height: 25),
        RatingsBreakdownWidget(ratingsBreakdown: reviewsState.ratingsBreakdown!),
        const SizedBox(height: 20),
        const Divider(),
        ListView.separated(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviewsState.reviews.length,
          itemBuilder: (context, index) {
            return ReviewListTile(review: reviewsState.reviews[index]);
          },
          separatorBuilder: (context, index) => Divider(height: 1, thickness: 1, color: Colors.grey[200]),
        ),
        if (reviewsState.status == ReviewsStatus.paginating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 90),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsState>(
      builder: (context, reviewsState, child) {
        switch (reviewsState.status) {
          case ReviewsStatus.loading:
            return _buildLoadingScreen();
          case ReviewsStatus.error:
            return Text(reviewsState.error.message);
          default:
            return _buildScreen(context, reviewsState);
        }
      },
    );
  }
}
