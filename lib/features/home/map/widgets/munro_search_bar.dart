import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MunroSearchBar extends StatefulWidget {
  final FocusNode focusNode;
  const MunroSearchBar({super.key, required this.focusNode});

  @override
  State<MunroSearchBar> createState() => _MunroSearchBarState();
}

class _MunroSearchBarState extends State<MunroSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
      child: CupertinoSearchTextField(
        focusNode: widget.focusNode,
        autocorrect: false,
        backgroundColor: Colors.grey[100],
        borderRadius: BorderRadius.circular(100),
        onChanged: (value) {
          // Filtering
        },
      ),
    );
  }
}
