import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/stat_text.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroScreen extends StatelessWidget {
  const MunroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          const MunroSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  munroNotifier.selectedMunro?.extra == null || munroNotifier.selectedMunro?.extra == ""
                      ? const SizedBox()
                      : SizedBox(width: double.infinity, child: Text("(${munroNotifier.selectedMunro?.extra})")),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      StatText(text: "Height", stat: "${munroNotifier.selectedMunro?.meters}m"),
                      StatText(text: "Area", stat: munroNotifier.selectedMunro?.area ?? ""),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const MunroDescription(),
                  const SizedBox(height: 20),
                  const MunroSummitedButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
