import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class NotificationIconButton extends StatelessWidget {
  const NotificationIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);
    return IconButton(
      onPressed: () {
        NotificationsService.getUserNotifications(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
      },
      icon: Stack(
        children: [
          const Icon(FontAwesomeIcons.bell, size: 22),
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
