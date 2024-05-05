import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifications/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    NotificationsState notificationsState = Provider.of<NotificationsState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          notificationsState.status != NotificationsStatus.paginating) {
        NotificationsService.paginateUserNotifications(context);
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
        NotificationsService.markAllNotificationsAsRead(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            NotificationsService.getUserNotifications(context);
          },
          child: notificationsState.notifications.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(15),
                  child: CenterText(text: "You have no notifications at the moment"),
                )
              : ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: notificationsState.notifications
                      .map(
                        (Notif notification) => NotificationTile(notification: notification),
                      )
                      .toList()),
        ),
      ),
    );
  }
}
