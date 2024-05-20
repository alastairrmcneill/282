import 'package:flutter/material.dart';

// Divider with text in the middle
class TextDivider extends StatelessWidget {
  final String text;
  const TextDivider({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            thickness: 1.5,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, height: 1.1),
          ),
        ),
        const Expanded(
          child: Divider(
            thickness: 1.5,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
