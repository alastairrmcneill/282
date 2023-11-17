import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MunroState>(
        builder: (context, munroState, child) {
          switch (munroState.status) {
            case MunroStatus.loading:
              return const LoadingWidget();
            case MunroStatus.error:
              return CenterText(text: munroState.error.message);
            case MunroStatus.loaded:
              return const MapScreen();
            default:
              return const LoadingWidget();
          }
        },
      ),
    );
  }
}
