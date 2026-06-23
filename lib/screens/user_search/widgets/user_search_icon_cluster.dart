import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class UserSearchIconCluster extends StatelessWidget {
  const UserSearchIconCluster({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colors.border,
              shape: BoxShape.circle,
            ),
            width: 90,
            height: 90,
            child: Icon(
              PhosphorIconsRegular.magnifyingGlass,
              size: 40,
              color: context.colors.textMuted,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.border,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              width: 36,
              height: 36,
              child: Icon(
                PhosphorIconsRegular.user,
                size: 18,
                color: context.colors.textMuted,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.border,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              width: 36,
              height: 36,
              child: Icon(
                PhosphorIconsRegular.mountains,
                size: 18,
                color: context.colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
