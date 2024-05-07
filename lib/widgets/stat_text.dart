import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class StatText extends StatelessWidget {
  final String text;
  final String stat;
  final String subStat;
  final Function()? onTap;
  const StatText({
    super.key,
    required this.text,
    required this.stat,
    this.subStat = "",
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
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: stat,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )),
                  TextSpan(
                      text: subStat,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      )),
                ],
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: MyColors.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
