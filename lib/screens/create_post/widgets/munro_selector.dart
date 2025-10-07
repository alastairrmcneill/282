import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroSelector extends StatefulWidget {
  const MunroSelector({super.key});

  @override
  State<MunroSelector> createState() => _MunroSelectorState();
}

class _MunroSelectorState extends State<MunroSelector> {
  void _showModalSheet(MunroState munroState, CreatePostState createPostState, FormFieldState formState) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Consumer<MunroState>(
              builder: (context, munroState, child) {
                return ListView(
                  children: [
                    const CreatePostMunroSearchbar(),
                    ...munroState.createPostFilteredMunroList.map((Munro munro) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              munro.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: munro.extra == "" ? Text(munro.area) : Text("${munro.extra} - ${munro.area}"),
                            trailing:
                                createPostState.selectedMunroIds.contains(munro.id) ? Icon(Icons.check_rounded) : null,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            onTap: () {
                              if (createPostState.selectedMunroIds.contains(munro.id)) {
                                createPostState.removeMunro(munro.id);
                              } else {
                                createPostState.addMunro(munro.id);
                              }
                              setState(() {});
                              setModalState(() {});
                              formState.didChange(createPostState.selectedMunroIds);
                            },
                          ),
                          Divider(),
                        ],
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    MunroState munroState = Provider.of<MunroState>(context);
    return FormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: createPostState.selectedMunroIds,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select at least one munro.";
        }
        return null;
      },
      builder: (FormFieldState formState) {
        return Column(
          children: [
            ...createPostState.selectedMunroIds.map((int munroId) {
              final munro = munroState.munroList.firstWhere((m) => m.id == munroId);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      munro.name,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 18),
                    ),
                    Text(
                      "${munro.extra == null || munro.extra!.isEmpty ? '' : '${munro.extra} - '}${munro.area}",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 5),
                    CreatePostImagePicker(munroId: munro.id),
                  ],
                ),
              );
            }),
            if (formState.hasError)
              Text(
                'Select at least one munro',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  munroState.setCreatePostFilterString = "";
                  _showModalSheet(munroState, createPostState, formState);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      Text(
                        "Add another munro",
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
