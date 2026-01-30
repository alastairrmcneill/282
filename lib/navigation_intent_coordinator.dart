import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

import 'app.dart';

class NavigationIntentCoordinator extends StatelessWidget {
  const NavigationIntentCoordinator({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final next = context.watch<NavigationIntentState>().next;

    if (next != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final intent = context.read<NavigationIntentState>().consumeNext();
        if (intent == null) return;

        await _handleIntent(context, intent);
      });
    }

    return child;
  }

  Future<void> _handleIntent(BuildContext context, NavigationIntent intent) async {
    switch (intent) {
      case OpenMunroIntent(:final munroId):
        final munroState = context.read<MunroState>();

        if (munroState.munroList.isEmpty) {
          await munroState.loadMunros();
        }

        munroState.setSelectedMunroId = munroId;
        final munro = munroState.munroList.firstWhere(
          (m) => m.id == munroId,
          orElse: () => Munro.empty,
        );
        munroState.setSelectedMunroId = munro.id;

        navigatorKey.currentState!.pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
        return;

      case OpenNotificationsIntent():
        final userId = context.read<UserState>().currentUser?.uid;
        if (userId == null) return;
        final notificationsState = context.read<NotificationsState>();
        await notificationsState.getUserNotifications();

        navigatorKey.currentState!.pushNamed(NotificationsScreen.route);
        return;

      case RefreshHomeIntent():
        // Example: could trigger refresh states rather than navigate.
        return;
    }
  }
}
