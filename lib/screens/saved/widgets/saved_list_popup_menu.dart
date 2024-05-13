import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/services/saved_list_service.dart';

class SavedListPopupMenu extends StatelessWidget {
  final SavedList savedList;
  const SavedListPopupMenu({super.key, required this.savedList});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(CupertinoIcons.ellipsis_vertical),
      onSelected: (value) async {
        if (value == MenuItems.item1) {
          if (savedList.uid != null) {
            showCreateSavedListDialog(context, savedList: savedList);
          }
        } else if (value == MenuItems.item2) {
          if (savedList.uid != null) {
            SavedListService.deleteSavedList(context, savedList: savedList);
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: MenuItems.item1,
          child: Text('Rename'),
        ),
        PopupMenuItem(
          value: MenuItems.item2,
          child: Text('Delete'),
        ),
      ],
    );
  }
}
