class MunroCommonlyClimbedWith {
  final int munroId;
  final int climbedWithId;
  final int togetherCount;

  MunroCommonlyClimbedWith({
    required this.munroId,
    required this.climbedWithId,
    required this.togetherCount,
  });

  static MunroCommonlyClimbedWith fromJSON(Map<String, dynamic> json) {
    return MunroCommonlyClimbedWith(
      munroId: json[MunrosCommonlyClimbedWithFields.munroId] as int,
      climbedWithId: json[MunrosCommonlyClimbedWithFields.climbedWithId] as int,
      togetherCount: json[MunrosCommonlyClimbedWithFields.togetherCount] as int,
    );
  }

  @override
  String toString() {
    return 'MunroCommonlyClimbedWith(munroId: $munroId, climbedWithId: $climbedWithId, togetherCount: $togetherCount)';
  }
}

class MunrosCommonlyClimbedWithFields {
  static const String munroId = 'munro_id';
  static const String climbedWithId = 'climbed_with_id';
  static const String togetherCount = 'together_count';
}
