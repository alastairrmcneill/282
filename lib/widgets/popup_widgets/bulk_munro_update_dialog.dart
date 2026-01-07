import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class BulkMunroUpdateDialog extends StatelessWidget {
  const BulkMunroUpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        width: 200.0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Have you already completed a Munro?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("You can bulk update your Munros to save marking them individually."),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final bulkMunroUpdateState = context.read<BulkMunroUpdateState>();
                  final munroCompletionState = context.read<MunroCompletionState>();
                  final munroState = context.read<MunroState>();

                  bulkMunroUpdateState.setStartingBulkMunroUpdateList = munroCompletionState.munroCompletions;
                  munroState.setBulkMunroUpdateFilterString = "";

                  Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
                },
                child: Text('Go'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
