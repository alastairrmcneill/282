import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifications/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  static const String route = '/notifications';
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    final notificationsState = context.read<NotificationsState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          notificationsState.status != NotificationsStatus.paginating) {
        notificationsState.paginateUserNotifications();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationsState>(
      builder: (context, notificationsState, child) {
        switch (notificationsState.status) {
          case NotificationsStatus.loading:
            return _buildLoadingScreen();
          case NotificationsStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: notificationsState.error.message),
            );
          default:
            return _buildScreen(context, notificationsState);
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 30,
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, NotificationsState notificationsState) {
    return PopScope(
      onPopInvoked: (didPop) {
        notificationsState.markAllNotificationsAsRead();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            notificationsState.getUserNotifications();
          },
          child: notificationsState.notifications.isEmpty
              ? const EmptyNotificationsList()
              : ListView.separated(
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: notificationsState.notifications.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      int unreadCount = notificationsState.notifications.where((notif) => !notif.read).length;
                      return UnreadNotificationTile(count: unreadCount);
                    }
                    final notification = notificationsState.notifications[index - 1];
                    return NotificationTile(notification: notification);
                  },
                ),
        ),
      ),
    );
  }
}
