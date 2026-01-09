import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
          const Icon(CupertinoIcons.bell, size: 22),
          notificationsState.notifications.where((element) => !element.read).isEmpty
              ? const SizedBox()
              : Positioned(
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      notificationsState.notifications.where((element) => !element.read).length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
        ],
      ),
    );
  }
}
