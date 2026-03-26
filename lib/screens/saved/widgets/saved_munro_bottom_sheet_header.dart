import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/support/theme.dart';

class SavedMunroBottomSheetHeader extends StatelessWidget {
  const SavedMunroBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Save to...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              PhosphorIconsRegular.x,
              color: MyColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
