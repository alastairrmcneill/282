import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SlidingPanelCollapsed extends StatelessWidget {
  final PanelController panelController;
  const SlidingPanelCollapsed({super.key, required this.panelController});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    int count = munroState.visibleMunroList.length;
    return GestureDetector(
      onTap: () => panelController.open(),
      child: Center(
        child: Text(
          count == 1 ? "$count Munro" : "$count Munros",
        ),
      ),
    );
  }
}
