import 'package:flutter/material.dart';
import 'package:two_eight_two/models/saved_list_model.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class CollapsedSavedListTile extends StatelessWidget {
  final SavedList savedList;
  final Function() onTap;
  const CollapsedSavedListTile({super.key, required this.savedList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            "${savedList.name} (${savedList.munroIds.length})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.keyboard_arrow_right_rounded),
          trailing: SavedListPopupMenu(savedList: savedList),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }
}