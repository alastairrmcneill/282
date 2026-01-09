import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class AnnualMunroChallengeDialog extends StatelessWidget {
  final Achievement achievement;

  const AnnualMunroChallengeDialog({super.key, required this.achievement});

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
              "Do you want to set a challenge for this year?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text("How many munros do you think you can complete?"),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Go'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
