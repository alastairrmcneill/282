import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroSummitsScreenArgs {
  final Munro munro;
  MunroSummitsScreenArgs({required this.munro});
}

class MunroSummitsScreen extends StatelessWidget {
  static const String route = '/munro/summits';
  final Munro munro;
  const MunroSummitsScreen({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.watch<MunroCompletionState>();

    List<MunroCompletion> munroCompletions =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munro.id).toList();

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
                    (mc) =>
                        MunroCompletionWidget(index: munroCompletions.indexOf(mc), munroCompletion: mc, munro: munro),
                  ),
                ],
              ),
            ),
    );
  }
}
