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
      initialValue: createPostState.selectedMunros,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Select at least one munro.";
        }
        return null;
      },
      builder: (FormFieldState formState) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Munros on this hike",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    munroState.setCreatePostFilterString = "";
                    _showModalSheet(munroState, createPostState, formState);
                  },
                  child: const Icon(
                    Icons.add_rounded,
                  ),
                ),
              ],
            ),
            ...createPostState.selectedMunros.map(
              (Munro munro) => Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 0),
                    title: Text(munro.name),
                    subtitle:
                        Text("${munro.extra == null || munro.extra!.isEmpty ? '' : '${munro.extra} - '}${munro.area}"),
                  ),
                  CreatePostImagePicker(munroId: munro.id),
                ],
              ),
            ),
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
