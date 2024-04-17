import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class SavedListTile extends StatefulWidget {
  final SavedList savedList;
  const SavedListTile({super.key, required this.savedList});

  @override
  State<SavedListTile> createState() => _SavedListTileState();
}

class _SavedListTileState extends State<SavedListTile> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return isExpanded
        ? ExpandedSavedListTile(
            savedList: widget.savedList,
            onTap: () => setState(() => isExpanded = false),
          )
        : CollapsedSavedListTile(
            savedList: widget.savedList,
            onTap: () => setState(() => isExpanded = true),
          );
  }
}
