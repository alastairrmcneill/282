import 'package:flutter/material.dart';

class StatText extends StatelessWidget {
  final String text;
  final int stat;
  final Function()? onTap;
  const StatText({
    super.key,
    required this.text,
    required this.stat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              stat.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
