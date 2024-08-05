import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSearchBar extends StatefulWidget {
  final FocusNode focusNode;
  final Function(Munro munro) onSelected;
  final VoidCallback onTap;
  const MunroSearchBar({super.key, required this.focusNode, required this.onSelected, required this.onTap});

  @override
  State<MunroSearchBar> createState() => _MunroSearchBarState();
}

class _MunroSearchBarState extends State<MunroSearchBar> {
  TextEditingController textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return TextField(
      controller: textEditingController,
      focusNode: widget.focusNode,
      autocorrect: false,
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: 'Search Munros',
        hintStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: MyColors.accentColor,
            width: 0.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: MyColors.accentColor,
            width: 0.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: MyColors.accentColor,
            width: 0.5,
          ),
        ),
        suffixIcon: textEditingController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: MyColors.accentColor,
                  size: 18,
                ),
                onPressed: () {
                  textEditingController.clear();
                  munroState.setFilterString = '';
                },
              )
            : null,
      ),
      onChanged: (value) {
        munroState.setFilterString = value;
      },
    );
  }
}
