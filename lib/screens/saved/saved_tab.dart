import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Scaffold(
      body: ListView(
        children: munroState.munroList
            .where((element) => element.saved)
            .map(
              (e) => ListTile(
                title: Text(e.name),
              ),
            )
            .toList(),
      ),
    );
  }
}
