import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/weather/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/stat_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroScreen extends StatefulWidget {
  const MunroScreen({super.key});

  static const String route = "/munro_screen";

  @override
  State<MunroScreen> createState() => _MunroScreenState();
}

class _MunroScreenState extends State<MunroScreen> {
  @override
  void initState() {
    MunroService.loadAdditionalMunroData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const MunroSummitedButton(),
      body: RefreshIndicator(
        onRefresh: () => MunroService.loadAdditionalMunroData(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const MunroSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    munroState.selectedMunro?.extra == null || munroState.selectedMunro?.extra == ""
                        ? const SizedBox()
                        : SizedBox(
                            width: double.infinity,
                            child: Text(
                              "(${munroState.selectedMunro?.extra})",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.w300),
                            ),
                          ),
                    const SizedBox(height: 15),
                    const MunroStatsRow(),
                    const SizedBox(height: 20),
                    const MunroDescription(),
                    const SizedBox(height: 20),
                    const DirectionsWidget(),
                    const SizedBox(height: 20),
                    const MunroPictureGallery(),
                    const SizedBox(height: 20),
                    const MunroWeatherWidget(),
                    const SizedBox(height: 20),
                    const MunroReviewsWidget(),
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
