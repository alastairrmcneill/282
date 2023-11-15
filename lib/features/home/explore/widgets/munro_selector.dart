import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class MunroSelector extends StatefulWidget {
  const MunroSelector({super.key});

  @override
  State<MunroSelector> createState() => _MunroSelectorState();
}

class _MunroSelectorState extends State<MunroSelector> {
  void _showModalSheet(MunroNotifier munroNotifier, CreatePostState createPostState, FormFieldState formState) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ListView(
              children: munroNotifier.munroList.map((Munro munro) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        munro.name,
                        style: TextStyle(fontSize: 14),
                      ),
                      subtitle: munro.extra == "" ? Text(munro.area) : Text("${munro.extra} - ${munro.area}"),
                      trailing: createPostState.selectedMunros.contains(munro) ? Icon(Icons.check_rounded) : null,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () {
                        if (createPostState.selectedMunros.contains(munro)) {
                          createPostState.removeMunro(munro);
                        } else {
                          createPostState.addMunro(munro);
                        }
                        setState(() {});
                        setModalState(() {});
                        formState.didChange(createPostState.selectedMunros);
                      },
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    return FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: createPostState.selectedMunros,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select at least one munro.";
        }
      },
      builder: (FormFieldState formState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Munros on this hike"),
                GestureDetector(
                  onTap: () => _showModalSheet(munroNotifier, createPostState, formState),
                  child: Icon(Icons.add_rounded),
                ),
              ],
            ),
            ...createPostState.selectedMunros.map((Munro munro) => Text(munro.name)).toList(),
            if (formState.hasError)
              Text(
                'Select at least one munro',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        );
      },
    );
  }
}
