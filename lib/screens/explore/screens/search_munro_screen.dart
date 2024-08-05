import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

class SearchMunroScreen extends StatelessWidget {
  const SearchMunroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: MyColors.backgroundColor,
      child: ListView.builder(
        itemCount: munroState.filteredMunroList.length,
        itemBuilder: (context, index) {
          Munro munro = munroState.filteredMunroList[index];
          return ListTile(
            title: Text(munro.name),
            onTap: () {
              munroState.setSelectedMunro = munro;
              MunroPictureService.getMunroPictures(context, munroId: munro.id, count: 4);
              ReviewService.getMunroReviews(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MunroScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
