import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(0),
        itemCount: 10,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ShimmerBox(width: double.infinity, height: 150, borderRadius: 12);
          }
          return ShimmerBox(width: double.infinity, height: 80, borderRadius: 12);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Text(message),
    );
  }

  Widget _buildEmptyScreen(ReviewsState reviewsState) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          RatingsBreakdownWidget(ratingsBreakdown: reviewsState.ratingsBreakdown!),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: context.colors.border,
              shape: BoxShape.circle,
            ),
            width: 80,
            height: 80,
            child: Icon(
              PhosphorIconsRegular.chatCircleDots,
              size: 35,
              color: context.colors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text('No Reviews Yet', style: textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(
            'Reviews from your adventures and the community will appear here. Be the first to share your experience!',
            style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(BuildContext context, ReviewsState reviewsState) {
    if (reviewsState.reviews.isEmpty) {
      return _buildEmptyScreen(reviewsState);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Column(
        children: [
          const SizedBox(height: 20),
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
      ),
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
            return _buildErrorScreen(reviewsState.error.message);
          case ReviewsStatus.loaded:
            return _buildScreen(context, reviewsState);
          case ReviewsStatus.paginating:
            return _buildScreen(context, reviewsState);
          default:
            return _buildLoadingScreen();
        }
      },
    );
  }
}
