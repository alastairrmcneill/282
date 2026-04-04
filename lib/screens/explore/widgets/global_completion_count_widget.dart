import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class GlobalCompletionCountWidget extends StatelessWidget {
  const GlobalCompletionCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GlobalCompletionState>();

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: context.colors.accent,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/mountain.svg',
              colorFilter: ColorFilter.mode(context.colors.accent, BlendMode.srcIn),
              width: 20,
              height: 20,
            ),
            Container(
              width: 0.5,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: context.colors.accent,
            ),
            AnimatedFlipCounter(
              value: state.globalCompletionCount,
              thousandSeparator: ',',
              textStyle: const TextStyle(height: 1.0),
            ),
          ],
        ),
      ),
    );
  }
}
