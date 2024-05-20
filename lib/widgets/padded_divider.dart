import 'package:flutter/material.dart';

class PaddedDivider extends StatelessWidget {
  final double top;
  final double bottom;
  final double left;
  final double right;
  const PaddedDivider({super.key, this.top = 15, this.bottom = 15, this.left = 0, this.right = 0});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom, left: left, right: right),
      child: const Divider(
        thickness: 1,
      ),
    );
  }
}
