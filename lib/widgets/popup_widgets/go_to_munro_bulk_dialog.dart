import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

// Custom error dialog with string input for any message
showGoToBulkMunroDialog(BuildContext context) async {
  // Check if if should show this dialog
  bool result = await SharedPreferencesService.getShowBulkMunroDialog();
  if (!result) return;

  Dialog dialog = Dialog(
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
          Text(
            "Have you already completed a Munro?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text("You can bulk update your Munros to save marking them individually."),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);
                UserState userState = Provider.of<UserState>(context, listen: false);
                MunroState munroState = Provider.of<MunroState>(context, listen: false);

                bulkMunroUpdateState.setBulkMunroUpdateList = userState.currentUser!.personalMunroData!;
                munroState.setBulkMunroUpdateFilterString = "";

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BulkMunroUpdateScreen()),
                );
              },
              child: Text('Go'),
            ),
          ),
        ],
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return dialog;
    },
  );
}
