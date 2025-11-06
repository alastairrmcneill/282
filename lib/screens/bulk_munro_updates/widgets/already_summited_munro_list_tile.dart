import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class AlreadySummitedMunroListTile extends StatelessWidget {
  final Munro munro;
  final DateTime summitedDate;
  const AlreadySummitedMunroListTile({super.key, required this.munro, required this.summitedDate});

  @override
  Widget build(BuildContext context) {
    TextEditingController dateController = TextEditingController(text: DateFormat('dd/MM/yy').format(summitedDate));
    return ListTile(
        title: Text(munro.name),
        subtitle: Text("${munro.extra == null || munro.extra!.isEmpty ? "" : "${munro.extra} · "}${munro.area}"),
        leading: const Icon(Icons.check),
        trailing: SizedBox(
          width: 100,
          child: TextFormFieldBase(
            controller: dateController,
            readOnly: true,
          ),
        ));
  }
}
