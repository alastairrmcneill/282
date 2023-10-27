import 'package:flutter/material.dart';

class ProfileMediaHistory extends StatelessWidget {
  const ProfileMediaHistory({super.key});

  @override
  Widget build(BuildContext context) {
    double height = 100;
    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
              height: height,
              width: height,
              margin: EdgeInsets.all(2),
              color: Colors.grey,
            ),
            Container(
              height: height,
              width: height,
              margin: EdgeInsets.all(2),
              color: Colors.grey,
            ),
            Container(
              height: height,
              width: height,
              margin: EdgeInsets.all(2),
              color: Colors.grey,
            ),
            Container(
              height: height,
              width: height,
              margin: EdgeInsets.all(2),
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
