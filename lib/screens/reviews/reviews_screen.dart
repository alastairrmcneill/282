import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});
  static const String route = '/reviews';

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    final reviewsState = context.read<ReviewsState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          reviewsState.status != ReviewsStatus.paginating) {
        reviewsState.paginateMunroReviews(1);
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
    int? munroId = context.read<MunroState>().selectedMunroId;
    String? munroName;
    if (munroId != null) {
      munroName = context.read<MunroState>().munroList.firstWhere((m) => m.id == munroId).name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Reviews'),
            if (munroName != null)
              Text(
                munroName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
              )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: RatingsBreakdownWidget(ratingsBreakdown: reviewsState.ratingsBreakdown!),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(child: Divider()),
            SliverToBoxAdapter(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviewsState.reviews.length,
                itemBuilder: (context, index) {
                  return ReviewListTile(review: reviewsState.reviews[index]);
                },
                separatorBuilder: (context, index) {
                  return Divider(height: 1, thickness: 1, color: Colors.grey[200]);
                },
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
