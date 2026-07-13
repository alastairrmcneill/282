import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedListHeader extends StatefulWidget {
  final SavedList savedList;
  const SavedListHeader({super.key, required this.savedList});

  @override
  State<SavedListHeader> createState() => _SavedListHeaderState();
}

class _SavedListHeaderState extends State<SavedListHeader> {
  bool _isEditing = false;
  late TextEditingController _nameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
    final items = [
      ActionMenuItems(
        title: 'Rename',
        onPressed: () {
          if (widget.savedList.uid != null) {
            _startEditing();
          }
        },
      ),
      ActionMenuItems(
        title: 'Delete',
        isDestructive: true,
        onPressed: () {
          if (widget.savedList.uid != null) {
            context.read<SavedListState>().deleteSavedList(savedList: widget.savedList);
          }
        },
      ),
    ];
    showActionSheet(context, items);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4, right: 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colors.divider,
              borderRadius: BorderRadius.circular(16),
            ),
            width: 44,
            height: 44,
            child: Icon(
              PhosphorIconsRegular.listDashes,
              color: context.colors.textSubtitle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _isEditing
                ? SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: AppTextFormField(
                              controller: _nameController,
                              autofocus: true,
                              hintText: "List name",
                              validator: (value) =>
                                  value == null || value.trim().isEmpty ? 'Name cannot be empty' : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: context.colors.accent, width: 0.65),
                              ),
                              fillColor: context.colors.background,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(PhosphorIconsRegular.check, color: Colors.green),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _saveEdit();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(PhosphorIconsRegular.x, color: Colors.red),
                          padding: EdgeInsets.all(4),
                          constraints: BoxConstraints(),
                          onPressed: _cancelEdit,
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.savedList.name, style: textTheme.titleMedium),
                      Text(
                        '${widget.savedList.munroIds.length} munro${widget.savedList.munroIds.length == 1 ? '' : 's'}',
                        style: textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
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
                  color: context.colors.textMuted,
                ),
                onPressed: () => _showActionsDialog(context),
              ),
            ),
          if (!_isEditing) const SizedBox(width: 8)
        ],
      ),
    );
  }
}
