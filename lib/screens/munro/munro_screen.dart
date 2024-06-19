import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroScreen extends StatefulWidget {
  const MunroScreen({super.key});

  static const String route = "/munro_screen";

  @override
  State<MunroScreen> createState() => _MunroScreenState();
}

class _MunroScreenState extends State<MunroScreen> {
  @override
  void initState() {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    print(munroState.selectedMunro?.toJSON());
    MunroService.loadAdditionalMunroData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const MunroSummitedButton(),
      body: RefreshIndicator(
        onRefresh: () => MunroService.loadAdditionalMunroData(context),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            MunroSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    MunroTitle(),
                    SizedBox(height: 25),
                    MunroStatsRow(),
                    SizedBox(height: 20),
                    MunroSummitedWidget(),
                    PaddedDivider(),
                    MunroDescription(),
                    PaddedDivider(top: 15, bottom: 5),
                    MunroDirectionsWidget(),
                    PaddedDivider(top: 5, bottom: 20),
                    MunroPictureGallery(),
                    PaddedDivider(),
                    MunroWeatherWidget(),
                    PaddedDivider(),
                    MunroReviewsWidget(),
                    SizedBox(height: 80),
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
