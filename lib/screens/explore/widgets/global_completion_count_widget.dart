import 'dart:ui';

import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class GlobalCompletionCountWidget extends StatelessWidget {
  const GlobalCompletionCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GlobalCompletionState>();

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Total bagged: ',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.light.surface),
                ),
                AnimatedFlipCounter(
                  value: state.globalCompletionCount,
                  thousandSeparator: ',',
                  textStyle: TextStyle(height: 1.0, color: AppColors.light.surface, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
