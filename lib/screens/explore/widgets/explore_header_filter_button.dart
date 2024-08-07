import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

import '../screens/screens.dart';

class ExploreHeaderFilterButton extends StatelessWidget {
  const ExploreHeaderFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 0,
        padding: const EdgeInsets.all(13),
        side: const BorderSide(
          color: MyColors.accentColor,
          width: 0.5,
        ),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const FilterScreen(),
          ),
        );
      },
      child: Stack(
        children: [
          const Icon(
            CupertinoIcons.slider_horizontal_3,
            color: MyColors.accentColor,
            size: 20,
          ),
          munroState.isFilterOptionsSet
              ? Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
