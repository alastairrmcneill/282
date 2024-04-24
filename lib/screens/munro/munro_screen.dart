import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
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
                        : SizedBox(width: double.infinity, child: Text("(${munroState.selectedMunro?.extra})")),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatText(
                            text: "Height",
                            stat: settingsState.metricHeight
                                ? "${munroState.selectedMunro?.meters}m"
                                : "${munroState.selectedMunro?.feet}ft"),
                        StatText(text: "Area", stat: munroState.selectedMunro?.area ?? ""),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const MunroDescription(),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        ...munroState.selectedMunro!.summitedDates!.map(
                          (e) => MunroCompletionWidget(
                              index: munroState.selectedMunro!.summitedDates!.indexOf(e) + 1, dateTime: e),
                        ),
                      ],
                    ),
                    const MunroSummitedButton(),
                    TextButton(
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse(munroState.selectedMunro?.startingPointURL ?? ""),
                        );
                      },
                      child: const Text("Starting Location"),
                    ),
                    const SizedBox(height: 20),
                    const MunroPictureGallery(),
                    const SizedBox(height: 20),
                    const Text('Reviews'),
                    const AverageMunroRating(),
                    const ReviewsListWidget(),
                    const MunroWeatherWidget(),
                    const SizedBox(height: 40),
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
