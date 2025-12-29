import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, required this.child});
  final Widget child;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemoteConfigState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rc = context.watch<RemoteConfigState>();

    if (rc.status == RemoteConfigStatus.initial || rc.status == RemoteConfigStatus.loading) {
      return const SplashScreen();
    }

    return widget.child;
  }
}
