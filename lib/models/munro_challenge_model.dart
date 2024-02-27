class MunroChallenge {
  final int year;
  final int target;
  final List<Map<String, dynamic>> completedMunros;

  MunroChallenge({
    required this.year,
    required this.target,
    required this.completedMunros,
  });

  Map<String, dynamic> toJSON() {
    return {
      MunroChallengeFields.year: year,
      MunroChallengeFields.target: target,
      MunroChallengeFields.completedMunros: completedMunros,
    };
  }

  static MunroChallenge fromJSON(Map<String, dynamic> json) {
    List<dynamic> completedMunros = json[MunroChallengeFields.completedMunros] as List<dynamic>;
    List<Map<String, dynamic>> completedMunrosList = [];
    for (var munro in completedMunros) {
      completedMunrosList.add(munro as Map<String, dynamic>);
    }

    return MunroChallenge(
      year: json[MunroChallengeFields.year] as int,
      target: json[MunroChallengeFields.target] as int,
      completedMunros: completedMunrosList,
    );
  }

  MunroChallenge copyWith({
    int? year,
    int? target,
    List<Map<String, dynamic>>? completedMunros,
  }) {
    return MunroChallenge(
      year: year ?? this.year,
      target: target ?? this.target,
      completedMunros: completedMunros ?? this.completedMunros,
    );
  }
}

class MunroChallengeFields {
  static const String year = 'year';
  static const String target = 'target';
  static const String completedMunros = 'completedMunros';
}
