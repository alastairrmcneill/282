import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/services/saved_list_service.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedListPopupMenu extends StatelessWidget {
  final SavedList savedList;
  const SavedListPopupMenu({super.key, required this.savedList});

  @override
  Widget build(BuildContext context) {
    List<MenuItem> menuItems = [
      MenuItem(
        text: 'Rename',
        onTap: () {
          if (savedList.uid != null) {
            showCreateSavedListDialog(context, savedList: savedList);
          }
        },
      ),
      MenuItem(
        text: 'Delete',
        onTap: () {
          if (savedList.uid != null) {
            SavedListService.deleteSavedList(context, savedList: savedList);
          }
        },
      ),
    ];
    return PopupMenuBase(items: menuItems);
  }
}
