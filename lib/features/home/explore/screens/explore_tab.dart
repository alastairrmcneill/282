import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/explore/screens/map_screen.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    NavigationState navigationState = Provider.of<NavigationState>(context);
    return Scaffold(
      body: MapScreen(),
    );
  }
}
