import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class MunroCompletionWidget extends StatelessWidget {
  final int index;
  final DateTime dateTime;
  const MunroCompletionWidget({super.key, required this.index, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Summit #${index + 1}'),
              Text('Date: $dateTime'),
            ],
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) async {
              if (value == MenuItems.item1) {
                // Remove
                MunroService.removeMunroCompletion(
                  context,
                  munro: munroState.selectedMunro!,
                  dateTime: dateTime,
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: MenuItems.item1,
                child: Text('Remove'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
