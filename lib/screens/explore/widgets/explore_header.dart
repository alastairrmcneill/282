import 'package:flutter/material.dart';

class ExploreTabHeader extends StatelessWidget {
  final double headerHeight;
  const ExploreTabHeader({super.key, required this.headerHeight});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.blue.withOpacity(0.5),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: Colors.red.withOpacity(0.5),
          height: headerHeight, // Fixed height of the header
          child: const Text(
            "This is the fixed header",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
