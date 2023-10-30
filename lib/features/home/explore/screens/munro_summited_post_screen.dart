import 'package:flutter/material.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/services/munro_service.dart';

class MunroSummitedPostScreen extends StatelessWidget {
  final Munro munro;
  const MunroSummitedPostScreen({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(children: [
        Text("Summited: ${munro.name}?"),
        SizedBox(
          height: 44,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await MunroService.markMunroAsDone(context, munro: munro);
              Navigator.of(context).pop();
            },
            child: Text("Save"),
          ),
        ),
      ]),
    );
  }
}
