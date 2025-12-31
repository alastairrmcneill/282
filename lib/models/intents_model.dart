sealed class AppIntent {
  const AppIntent();

  String get dedupeKey;
}

final class OpenMunroIntent extends AppIntent {
  final int munroId;
  const OpenMunroIntent({required this.munroId});

  @override
  String get dedupeKey => 'open_munro:$munroId';
}

final class RefreshHomeIntent extends AppIntent {
  const RefreshHomeIntent();

  @override
  String get dedupeKey => 'refresh_home';
}
