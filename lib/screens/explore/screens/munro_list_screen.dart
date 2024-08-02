import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import '../../../models/models.dart';

class MunroListScreen extends StatelessWidget {
  final ScrollController scrollController;
  final PanelController panelController;

  const MunroListScreen({super.key, required this.scrollController, required this.panelController});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 40, bottom: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: munroState.visibleMunroList.map((Munro munro) {
                return MunroCard(munro: munro);
              }).toList(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  panelController.close();
                  scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.map),
                    SizedBox(width: 8),
                    Text("Map"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
