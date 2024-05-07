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
  const MunroSearchBar({super.key, required this.focusNode, required this.onSelected});

  @override
  State<MunroSearchBar> createState() => _MunroSearchBarState();
}

class _MunroSearchBarState extends State<MunroSearchBar> {
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: Column(
        children: [
          CupertinoSearchTextField(
            focusNode: widget.focusNode,
            autocorrect: false,
            backgroundColor: MyColors.backgroundColor,
            borderRadius: BorderRadius.circular(11),
            onChanged: (value) {
              munroState.setFilterString = value;
            },
            itemSize: 22,
          ),
          const SizedBox(height: 2),
          munroState.filteredMunroList.isNotEmpty
              ? SizedBox(
                  height: 200,
                  child: MunroFilterList(
                    onSelected: (munro) {
                      widget.onSelected(munro);
                    },
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}
