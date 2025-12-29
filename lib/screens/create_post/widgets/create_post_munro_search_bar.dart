import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CreatePostMunroSearchbar extends StatelessWidget {
  const CreatePostMunroSearchbar({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: CupertinoSearchTextField(
        autocorrect: false,
        backgroundColor: Colors.grey[100],
        borderRadius: BorderRadius.circular(100),
        onChanged: (value) {
          munroState.setCreatePostFilterString = value;
        },
      ),
    );
  }
}
