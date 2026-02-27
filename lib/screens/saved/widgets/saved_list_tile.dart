import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class SavedListTile extends StatefulWidget {
  final SavedList savedList;
  const SavedListTile({super.key, required this.savedList});

  @override
  State<SavedListTile> createState() => _SavedListTileState();
}

class _SavedListTileState extends State<SavedListTile> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.savedList.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      _nameController.text = widget.savedList.name;
    });
  }

  void _saveEdit() async {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != widget.savedList.name) {
      final updatedList = widget.savedList.copy(name: newName);
      context.read<SavedListState>().updateSavedListName(savedList: updatedList);
    }
    setState(() {
      _isEditing = false;
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = widget.savedList.name;
    });
  }

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
              Navigator.pop(context);
              if (widget.savedList.uid != null) {
                _startEditing();
              }
            },
            child: const Text('Rename'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              if (widget.savedList.uid != null) {
                context.read<SavedListState>().deleteSavedList(savedList: widget.savedList);
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
                Navigator.pop(context);
                if (widget.savedList.uid != null) {
                  _startEditing();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<SavedListState>().deleteSavedList(savedList: widget.savedList);
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
                  child: _isEditing
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                autofocus: true,
                                style: textTheme.titleMedium,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                  border: OutlineInputBorder(),
                                ),
                                onSubmitted: (_) => _saveEdit(),
                              ),
                            ),
                            IconButton(
                              icon: Icon(PhosphorIconsRegular.check, color: Colors.green),
                              padding: EdgeInsets.all(4),
                              constraints: BoxConstraints(),
                              onPressed: _saveEdit,
                            ),
                            IconButton(
                              icon: Icon(PhosphorIconsRegular.x, color: Colors.red),
                              padding: EdgeInsets.all(4),
                              constraints: BoxConstraints(),
                              onPressed: _cancelEdit,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.savedList.name, style: textTheme.titleMedium),
                            Text(
                              '${widget.savedList.munroIds.length} munro${widget.savedList.munroIds.length == 1 ? '' : 's'}',
                              style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
                            ),
                          ],
                        ),
                ),
                if (!_isEditing)
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
                if (!_isEditing) const SizedBox(width: 8)
              ],
            ),
            const SizedBox(height: 10),
            widget.savedList.munroIds.isEmpty
                ? SavedListEmptyMunroList()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.savedList.munroIds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final munroId = widget.savedList.munroIds[index];
                      final Munro munro = munroState.munroList.where((m) => m.id == munroId).first;
                      return SavedListMunroTile(
                        munro: munro,
                        onDelete: () async {
                          await context
                              .read<SavedListState>()
                              .removeMunroFromSavedList(savedList: widget.savedList, munroId: munroId);
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
