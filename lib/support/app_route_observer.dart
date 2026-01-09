import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/screens/screens.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  AppRouteObserver(this._analytics);

  final Analytics _analytics;

  String? _previousScreen;
  DateTime? _previousScreenStartTime;

  @override
  void didPush(Route route, Route? previousRoute) {
    _trackScreenTransition(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _trackScreenTransition(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _trackScreenTransition(previousRoute, route);
    super.didPop(route, previousRoute);
  }

  void _trackScreenTransition(Route? newRoute, Route? oldRoute) {
    final newScreen = _getScreenName(newRoute);

    if (newScreen == null || newScreen == _previousScreen) return;

    final now = DateTime.now();

    if (_previousScreen != null && _previousScreenStartTime != null) {
      final duration = now.difference(_previousScreenStartTime!);
      _analytics.track(
        AnalyticsEvent.screenViewed,
        props: {
          AnalyticsProp.screen: newScreen,
          AnalyticsProp.previousScreen: _previousScreen!,
          AnalyticsProp.durationSeconds: duration.inSeconds,
        },
      );
    } else {
      _analytics.track(
        AnalyticsEvent.screenViewed,
        props: {
          AnalyticsProp.screen: newScreen,
        },
      );
    }

    _previousScreen = newScreen;
    _previousScreenStartTime = now;
  }

  String? _getScreenName(Route? route) {
    if (route is PageRoute) {
      final name = route.settings.name;
      if (name != null && name.isNotEmpty) {
        if (name == '/' || name == HomeScreen.route) {
          return _getActiveTabRouteFromHome();
        }
        return name;
      }
    }
    return null;
  }

  String? _getActiveTabRouteFromHome() {
    return homeScreenKey.currentState?.currentTabRoute;
  }

  void updateCurrentScreen(String newScreen) {
    // keep if you truly need manual overrides, otherwise delete
    final now = DateTime.now();
    if (newScreen == _previousScreen) return;

    if (_previousScreen != null && _previousScreenStartTime != null) {
      final duration = now.difference(_previousScreenStartTime!);
      _analytics.track(
        AnalyticsEvent.screenViewed,
        props: {
          AnalyticsProp.screen: newScreen,
          AnalyticsProp.previousScreen: _previousScreen!,
          AnalyticsProp.durationSeconds: duration.inSeconds,
        },
      );
    } else {
      _analytics.track(
        AnalyticsEvent.screenViewed,
        props: {AnalyticsProp.screen: newScreen},
      );
    }

    _previousScreen = newScreen;
    _previousScreenStartTime = now;
  }
}
