import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class RecordTab extends StatelessWidget {
  const RecordTab({super.key});

  @override
  Widget build(BuildContext context) {
    FlavorState flavorState = Provider.of<FlavorState>(context);
    return Scaffold(
      body: Center(child: Text(flavorState.flavor)),
    );
  }
}
