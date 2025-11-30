import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    AnalyticsService.logMunroViewed(
      munroId: (munroState.selectedMunro?.id ?? 0).toString(),
      munroName: munroState.selectedMunro?.name ?? "",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Scaffold(
      floatingActionButton: const MunroSummitedButton(),
      body: RefreshIndicator(
        onRefresh: () => munroState.loadMunros(),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const MunroSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    const MunroTitle(),
                    const SizedBox(height: 25),
                    MunroStatsRow(
                      onReviewsTap: () {
                        final context = _reviewsKey.currentContext;
                        if (context != null) {
                          Scrollable.ensureVisible(context, duration: const Duration(seconds: 1));
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    const MunroSummitedWidget(),
                    const PaddedDivider(),
                    const MunroDescription(),
                    const PaddedDivider(top: 15, bottom: 5),
                    const MunroDirectionsWidget(),
                    const PaddedDivider(top: 5, bottom: 20),
                    const MunroPictureGallery(),
                    const PaddedDivider(),
                    const MunroWeatherWidget(),
                    const PaddedDivider(),
                    MunroReviewsWidget(key: _reviewsKey),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
