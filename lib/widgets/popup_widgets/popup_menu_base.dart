import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/enums/enums.dart';

class PopupMenuBase extends StatelessWidget {
  final List<MenuItem> items;

  const PopupMenuBase({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(CupertinoIcons.ellipsis_vertical),
      onSelected: (value) => items[value].onTap(),
      itemBuilder: (context) => items.map((item) {
        return PopupMenuItem<int>(
          value: items.indexOf(item),
          child: Text(
            item.text,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w400),
          ),
        );
      }).toList(),
    );
  }
}
