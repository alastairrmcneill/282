import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/profile/screens/screens.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class MunroProgressIndicator extends StatelessWidget {
  const MunroProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const MunrosSummitedPage(),
        ),
      ),
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Munros",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 20),
            Column(
              children: [
                CircularPercentIndicator(
                  radius: 25,
                  lineWidth: 4,
                  backgroundColor: Colors.black12,
                  progressColor: Colors.green,
                  percent:
                      munroNotifier.munroList.where((munro) => munro.summited).length /
                          munroNotifier.munroList.length,
                  center: Text(
                      "${((munroNotifier.munroList.where((munro) => munro.summited).length / munroNotifier.munroList.length) * 100).round()}%"),
                ),
                Text(
                    "${munroNotifier.munroList.where((munro) => munro.summited).length}/${munroNotifier.munroList.length}"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
