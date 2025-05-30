import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroAreaScreenArgs {
  final String area;
  MunroAreaScreenArgs({required this.area});
}

class MunroAreaScreen extends StatelessWidget {
  static const String route = '/munro/area';
  final MunroAreaScreenArgs args;
  const MunroAreaScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    String area = args.area;
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    List<Munro> munros = munroState.munroList.where((munro) => munro.area == area).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(area),
      ),
      body: ListView.builder(
        itemCount: munros.length,
        itemBuilder: (context, index) {
          Munro munro = munros[index];
          return MunroSearchListTile(munro: munro);
        },
      ),
    );
  }
}
