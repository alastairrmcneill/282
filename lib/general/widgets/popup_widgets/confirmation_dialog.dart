import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String message;
  final Future<void> Function() onConfirm;
  const ConfirmationDialog({
    Key? key,
    required this.message,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS ? _showIOSDialog(context) : _showAndroidDialog(context);
  }

  AlertDialog _showAndroidDialog(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      actions: [
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(decoration: TextDecoration.none),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(
            'Confirm',
            style: TextStyle(decoration: TextDecoration.none, color: Colors.red),
          ),
          onPressed: () async {
            await onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  CupertinoAlertDialog _showIOSDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(message),
      actions: [
        CupertinoDialogAction(
          child: const Text(
            'Cancel',
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        CupertinoDialogAction(
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            await onConfirm();
          },
        ),
      ],
    );
  }
}

showConfirmationDialog(
  BuildContext context, {
  required String message,
  required Future<void> Function() onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) => ConfirmationDialog(
      message: message,
      onConfirm: onConfirm,
    ),
  );
}
