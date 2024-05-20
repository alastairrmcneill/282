import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final Future Function() onPressed;
  final double height;
  final double width;
  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 44,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
