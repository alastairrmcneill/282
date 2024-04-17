import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/saved_list_service.dart';

// Show dialog to add historical entry to an account
showSaveMunroDialog(BuildContext context) {
  MunroState munroState = Provider.of<MunroState>(context, listen: false);
  SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);

  Future submitForm() async {}

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
                  ...savedListState.savedLists.map(
                    (e) => CheckboxListTile(
                      value: e.munroIds.contains(munroState.selectedMunro?.id),
                      onChanged: (value) async {
                        if (value == true) {
                          await SavedListService.addMunroToSavedList(
                            context,
                            savedList: e,
                            munroId: munroState.selectedMunro?.id ?? "",
                          );
                          setState(() {});
                        } else {
                          await SavedListService.removeMunroFromSavedList(
                            context,
                            savedList: e,
                            munroId: munroState.selectedMunro?.id ?? "",
                          );
                          setState(() {});
                        }
                      },
                      title: Text(e.name),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit form button
              SizedBox(
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
