import 'package:flutter/material.dart';

class PaddedDivider extends StatelessWidget {
  final double top;
  final double bottom;
  const PaddedDivider({super.key, this.top = 15, this.bottom = 15});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: bottom),
      child: const Divider(
        thickness: 1,
      ),
    );
  }
}
