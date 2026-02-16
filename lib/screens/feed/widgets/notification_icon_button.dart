import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationsState = context.read<NotificationsState>();
    return IconButton(
      onPressed: () {
        notificationsState.getUserNotifications();
        Navigator.of(context).pushNamed(NotificationsScreen.route);
      },
      icon: Stack(
        children: [
          const Icon(PhosphorIconsRegular.bell, size: 22),
          notificationsState.notifications.where((element) => !element.read).isEmpty
              ? const SizedBox()
              : Positioned(
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
