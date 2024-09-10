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

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Stack(
        children: [
          SizedBox(
            height: 44,
            width: 44,
            child: Center(
              child: ElevatedButton(
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
                child: const Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: MyColors.accentColor,
                  size: 20,
                ),
              ),
            ),
          ),
          if (munroState.isFilterOptionsSet) // TODO: change what this is checking for
            Positioned(
              right: 7,
              top: 7,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
