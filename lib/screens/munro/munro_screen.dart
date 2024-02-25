import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/reviews/widgets/widgets.dart';
import 'package:two_eight_two/services/munro_service.dart';
import 'package:two_eight_two/widgets/stat_text.dart';

class MunroScreen extends StatefulWidget {
  const MunroScreen({super.key});

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
                        StatText(text: "Height", stat: "${munroState.selectedMunro?.meters}m"),
                        StatText(text: "Area", stat: munroState.selectedMunro?.area ?? ""),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const MunroDescription(),
                    const SizedBox(height: 20),
                    const MunroSummitedButton(),
                    const SizedBox(height: 20),
                    const MunroPictureGallery(),
                    const SizedBox(height: 20),
                    const Text('Reviews'),
                    const AverageMunroRating(),
                    const ReviewsListWidget(),
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
