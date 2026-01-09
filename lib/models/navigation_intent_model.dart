sealed class NavigationIntent {
  const NavigationIntent();

  String get dedupeKey;
}

final class OpenMunroIntent extends NavigationIntent {
  final int munroId;
  const OpenMunroIntent({required this.munroId});

  @override
  String get dedupeKey => 'open_munro:$munroId';
}

final class RefreshHomeIntent extends NavigationIntent {
  const RefreshHomeIntent();

  @override
  String get dedupeKey => 'refresh_home';
}

final class OpenNotificationsIntent extends NavigationIntent {
  const OpenNotificationsIntent();

  @override
  String get dedupeKey => 'open_notifications';
}
