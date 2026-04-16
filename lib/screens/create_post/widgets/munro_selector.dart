import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
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
    final createPostState = context.watch<CreatePostState>();
    final munroState = context.watch<MunroState>();
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
              final munro = munroState.munroList.firstWhere(
                (m) => m.id == munroId,
                orElse: () => Munro.empty,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 22,
                              color: context.colors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                munro.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                createPostState.removeMunro(munro.id);
                                setState(() {});
                                formState.didChange(createPostState.selectedMunroIds);
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: context.colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Text(
                            '${munro.meters}m • ${munro.area}',
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: context.colors.textMuted),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Photos (optional)',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: context.colors.textMuted),
                        ),
                        const SizedBox(height: 8),
                        CreatePostImagePicker(munroId: munro.id),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (formState.hasError)
              Text(
                'Select at least one munro',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  munroState.setCreatePostFilterString = "";
                  _showModalSheet(munroState, createPostState, formState);
                },
                icon: const Icon(Icons.add),
                label: const Text('Add another munro'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
