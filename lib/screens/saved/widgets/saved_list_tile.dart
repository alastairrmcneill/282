import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class SavedListTile extends StatelessWidget {
  final SavedList savedList;
  const SavedListTile({super.key, required this.savedList});

  void _showActionsDialog(BuildContext context) {
    if (Platform.isIOS) {
      _showIOSActionSheet(context);
    } else {
      _showAndroidBottomSheet(context);
    }
  }

  void _showIOSActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              if (savedList.uid != null) {
                showCreateSavedListDialog(context,
                    savedList:
                        savedList); // TODO can we do something like in line editing or new screen rather than the popup
              }
            },
            child: const Text('Rename'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              if (savedList.uid != null) {
                context.read<SavedListState>().deleteSavedList(savedList: savedList);
                Navigator.pop(context);
              }
            },
            isDestructiveAction: true,
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showAndroidBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                if (savedList.uid != null) {
                  showCreateSavedListDialog(context, savedList: savedList);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<SavedListState>().deleteSavedList(savedList: savedList);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                    decoration: BoxDecoration(color: MyColors.lightGrey, borderRadius: BorderRadius.circular(8)),
                    width: 30,
                    height: 30,
                    child: Icon(
                      PhosphorIconsRegular.listDashes,
                      color: MyColors.mutedText,
                    )),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(savedList.name, style: textTheme.titleMedium),
                      Text(
                        '${savedList.munroIds.length} munro${savedList.munroIds.length == 1 ? '' : 's'}',
                        style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    padding: EdgeInsets.all(0),
                    icon: Icon(
                      PhosphorIconsBold.dotsThreeVertical,
                      color: MyColors.mutedText,
                    ),
                    onPressed: () => _showActionsDialog(context),
                  ),
                ),
                const SizedBox(width: 8)
              ],
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: savedList.munroIds.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final munroId = savedList.munroIds[index];
                final Munro munro = munroState.munroList.where((m) => m.id == munroId).first;
                return SavedListMunroTile(
                  munro: munro,
                  onDelete: () async {
                    await context
                        .read<SavedListState>()
                        .removeMunroFromSavedList(savedList: savedList, munroId: munroId);
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
