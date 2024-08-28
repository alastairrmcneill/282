import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';

class ExploreHeaderGroupButton extends StatelessWidget {
  const ExploreHeaderGroupButton({super.key});

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
                      builder: (_) => const GroupFilterScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    const Icon(
                      CupertinoIcons.person_2,
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
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                child: Center(
                  child: Text(
                    'New',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      height: 0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
