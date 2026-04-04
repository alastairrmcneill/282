import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CreatePostMunroSelector extends StatelessWidget {
  const CreatePostMunroSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final createPostState = context.watch<CreatePostState>();
    final munroState = context.read<MunroState>();
    return Column(
      children: [
        Row(
          children: [
            Text('Munros'),
            TextButton(child: Text('+ Add munro'), onPressed: () {}),
          ],
        ),
        ...createPostState.selectedMunroIds.map((munroId) {
          final munro = munroState.munroList.firstWhere(
            (m) => m.id == munroId,
            orElse: () => Munro.empty,
          );
          return Text(munro.name);
        }),
      ],
    );
  }
}
