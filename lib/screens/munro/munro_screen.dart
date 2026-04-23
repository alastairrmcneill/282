import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroScreenArgs {
  final Munro munro;
  MunroScreenArgs({required this.munro});
}

class MunroScreen extends StatefulWidget {
  static const String route = "/munro";
  const MunroScreen({super.key});

  @override
  State<MunroScreen> createState() => _MunroScreenState();
}

class _MunroScreenState extends State<MunroScreen> {
  final ScrollController _scrollController = ScrollController();

  static const double _heroExpandedHeight = 300.0;
  static const double _heroOverlap = 15.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final munroDetailState = context.read<MunroDetailState>();
      context.read<ReviewsState>().getMunroReviewsAndRatings(munroDetailState.selectedMunro!.id);

      context.read<Analytics>().track(
        AnalyticsEvent.munroViewed,
        props: {
          AnalyticsProp.munroId: (munroDetailState.selectedMunro?.id ?? 0).toString(),
          AnalyticsProp.munroName: munroDetailState.selectedMunro?.name ?? "",
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.watch<MunroDetailState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final Munro munro = munroDetailState.selectedMunro!;
    final bool isBagged = munroCompletionState.isBagged(munro);
    final completions = munroCompletionState.munroCompletions.where((mc) => mc.munroId == munro.id).toList();

    // Reserve space below the hero for the non-overlapping portion of the card.
    // Card height is ~120px for 1 completion, ~20px taller per additional completion.
    final double cardHeight = completions.isEmpty ? 0 : 114 + (completions.length - 1) * 20.0;
    final double spacerHeight = (cardHeight - _heroOverlap).clamp(0.0, double.infinity);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              MunroSliverAppBar(munro: munro),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (isBagged) SizedBox(height: spacerHeight),
                    MunroDetailsTabs(munro: munro, scrollController: _scrollController),
                  ],
                ),
              ),
            ],
          ),
          if (isBagged)
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, _) {
                final topPadding = MediaQuery.of(context).padding.top;
                final scrollOffset = _scrollController.hasClients ? _scrollController.offset : 0.0;
                final top = _heroExpandedHeight + topPadding - _heroOverlap - scrollOffset;
                final collapsedBarHeight = kToolbarHeight + topPadding;
                final opacity = ((top + cardHeight - collapsedBarHeight) / cardHeight).clamp(0.0, 1.0);

                return Positioned(
                  top: top,
                  left: 15,
                  right: 15,
                  child: Opacity(
                    opacity: opacity,
                    child: MunroSummitedWidget(munro: munro),
                  ),
                );
              },
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: context.colors.border,
                    width: 0.6,
                  ),
                ),
              ),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SafeArea(
                  bottom: true,
                  top: false,
                  left: true,
                  right: true,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: MunroBottomButtons(munro: munro, isBagged: isBagged),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
