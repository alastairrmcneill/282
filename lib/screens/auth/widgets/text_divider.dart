import 'package:flutter/material.dart';

// Divider with text in the middle
class TextDivider extends StatelessWidget {
  final String text;
  final Color? color;
  const TextDivider({Key? key, required this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            thickness: 0.5,
            color: color ?? Theme.of(context).dividerColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: TextStyle(color: color ?? Theme.of(context).dividerColor, fontWeight: FontWeight.w400, height: 1),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 0.5,
            color: color ?? Theme.of(context).dividerColor,
          ),
        ),
      ],
    );
  }
}
