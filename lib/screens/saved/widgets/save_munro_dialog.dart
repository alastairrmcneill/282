import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

// Show dialog to add historical entry to an account
showSaveMunroDialog(BuildContext context) {
  final munroState = context.read<MunroState>();
  final savedListState = context.read<SavedListState>();

  AlertDialog alert = AlertDialog(
    scrollable: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    content: StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Form
              Column(
                children: [
                  // Title
                  const Text('Save Munro'),
                  const SizedBox(height: 20),
                  savedListState.savedLists.isEmpty
                      ? const Text('You have no saved lists')
                      : Column(
                          children: savedListState.savedLists
                              .map(
                                (e) => CheckboxListTile(
                                  value: e.munroIds.contains(munroState.selectedMunro?.id),
                                  onChanged: (value) async {
                                    if (value == true) {
                                      await savedListState.addMunroToSavedList(
                                        savedList: e,
                                        munroId: munroState.selectedMunro?.id ?? 0,
                                      );
                                      setState(() {});
                                    } else {
                                      await savedListState.removeMunroFromSavedList(
                                        savedList: e,
                                        munroId: munroState.selectedMunro?.id ?? 0,
                                      );
                                      setState(() {});
                                    }
                                  },
                                  title: Text(e.name),
                                ),
                              )
                              .toList(),
                        ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit form button
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              )
            ],
          ),
        );
      },
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
