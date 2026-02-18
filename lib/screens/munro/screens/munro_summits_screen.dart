import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroSummitsScreen extends StatelessWidget {
  static const String route = '/munro/summits';
  const MunroSummitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    final munroCompletionState = context.watch<MunroCompletionState>();

    List<MunroCompletion> munroCompletions =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munroState.selectedMunroId).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summits'),
      ),
      body: munroCompletions.isEmpty
          ? const CenterText(text: "You haven't summited this Munro yet.")
          : SingleChildScrollView(
              child: Column(
                children: [
                  ...munroCompletions.map(
                    (mc) => MunroCompletionWidget(index: munroCompletions.indexOf(mc), munroCompletion: mc),
                  ),
                ],
              ),
            ),
    );
  }
}
