import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_post/select_munros_screen.dart';
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
  final GlobalKey _reviewsKey = GlobalKey();

  @override
  void initState() {
    final munroDetailState = context.read<MunroDetailState>();
    context.read<Analytics>().track(
      AnalyticsEvent.munroViewed,
      props: {
        AnalyticsProp.munroId: (munroDetailState.selectedMunro?.id ?? 0).toString(),
        AnalyticsProp.munroName: munroDetailState.selectedMunro?.name ?? "",
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.watch<MunroDetailState>();
    final munroCompletionState = context.watch<MunroCompletionState>();
    final Munro munro = munroDetailState.selectedMunro!;

    return Scaffold(
      // floatingActionButton: MunroSummitedButton(munro: munro),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              MunroSliverAppBar(munro: munro),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      MunroSummitedWidget(munro: munro),
                      munro.id % 2 == 0
                          ? MunroDetailsTabs(munro: munro)
                          : MunroDetailsScroll(munro: munro), // TODO - remove
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0, 0.85, 1],
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor,
                    Theme.of(context).scaffoldBackgroundColor.withAlpha(0),
                  ],
                ),
              ),
              width: double.infinity,
              child: SafeArea(
                bottom: true,
                top: false,
                left: true,
                right: true,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        SelectMunrosScreen.route,
                        arguments: SelectMunrosScreenArgs(mainMunro: munro),
                      );
                    },
                    child: Text(munroCompletionState.isBagged(munro) ? 'Log Another Climb' : 'Log A Climb'),
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
