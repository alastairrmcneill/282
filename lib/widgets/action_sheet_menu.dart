import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionMenuItems {
  final String title;
  final bool isDestructive;
  final VoidCallback onPressed;

  ActionMenuItems({
    required this.title,
    required this.onPressed,
    this.isDestructive = false,
  });
}

void showActionSheet(BuildContext context, List<ActionMenuItems> items) {
  if (Platform.isIOS) {
    _showIOSActionSheet(context, items);
  } else {
    _showAndroidBottomSheet(context, items);
  }
}

void _showIOSActionSheet(BuildContext context, List<ActionMenuItems> items) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      actions: items
          .map(
            (item) => CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                item.onPressed();
              },
              isDestructiveAction: item.isDestructive,
              child: Text(item.title),
            ),
          )
          .toList(),
      cancelButton: CupertinoActionSheetAction(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
    ),
  );
}

void _showAndroidBottomSheet(BuildContext context, List<ActionMenuItems> items) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items
            .map(
              (item) => ListTile(
                leading: item.isDestructive ? const Icon(Icons.delete, color: Colors.red) : null,
                title: Text(item.title),
                onTap: () {
                  Navigator.pop(context);
                  item.onPressed();
                },
              ),
            )
            .toList(),
      ),
    ),
  );
}
