import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroSummitsScreen extends StatelessWidget {
  const MunroSummitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    int summitCount = munroState.selectedMunro!.summitedDates?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summits'),
      ),
      body: summitCount == 0
          ? const CenterText(text: "You haven't summited this Munro yet.")
          : SingleChildScrollView(
              child: Column(
                children: [
                  ...munroState.selectedMunro!.summitedDates!.map(
                    (e) =>
                        MunroCompletionWidget(index: munroState.selectedMunro!.summitedDates!.indexOf(e), dateTime: e),
                  ),
                ],
              ),
            ),
    );
  }
}
