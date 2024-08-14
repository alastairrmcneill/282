import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class PageProgressIndicator extends StatelessWidget {
  final int currentPageIndex;
  final int totalPages;

  const PageProgressIndicator({super.key, required this.currentPageIndex, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: List.generate(totalPages, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                height: 4.0,
                decoration: BoxDecoration(
                  color: index <= currentPageIndex ? MyColors.accentColor : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
