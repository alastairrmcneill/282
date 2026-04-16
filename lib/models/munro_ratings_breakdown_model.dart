class MunroRatingsBreakdown {
  final int munroId;
  final double averageRating;
  final int totalRatings;
  final int rating5Count;
  final int rating4Count;
  final int rating3Count;
  final int rating2Count;
  final int rating1Count;

  MunroRatingsBreakdown({
    required this.munroId,
    required this.averageRating,
    required this.totalRatings,
    required this.rating5Count,
    required this.rating4Count,
    required this.rating3Count,
    required this.rating2Count,
    required this.rating1Count,
  });

  factory MunroRatingsBreakdown.fromJSON(Map<String, dynamic> json) {
    return MunroRatingsBreakdown(
      munroId: json[MunroRatingsBreakdownFields.munroId] as int,
      averageRating: (json[MunroRatingsBreakdownFields.averageRating] as num).toDouble(),
      totalRatings: json[MunroRatingsBreakdownFields.totalRatings] as int,
      rating5Count: json[MunroRatingsBreakdownFields.rating5Count] as int,
      rating4Count: json[MunroRatingsBreakdownFields.rating4Count] as int,
      rating3Count: json[MunroRatingsBreakdownFields.rating3Count] as int,
      rating2Count: json[MunroRatingsBreakdownFields.rating2Count] as int,
      rating1Count: json[MunroRatingsBreakdownFields.rating1Count] as int,
    );
  }

  @override
  String toString() {
    return '''MunroRatingsBreakdown(munroId: $munroId, 
            averageRating: $averageRating,
            totalRatings: $totalRatings, 
            rating5Count: $rating5Count, 
            rating4Count: $rating4Count, 
            rating3Count: $rating3Count, 
            rating2Count: $rating2Count, 
            rating1Count: $rating1Count)''';
  }
}

class MunroRatingsBreakdownFields {
  static const String munroId = 'munro_id';
  static const String averageRating = 'average_rating';
  static const String totalRatings = 'total_reviews_count';
  static const String rating5Count = 'rating_5_count';
  static const String rating4Count = 'rating_4_count';
  static const String rating3Count = 'rating_3_count';
  static const String rating2Count = 'rating_2_count';
  static const String rating1Count = 'rating_1_count';
}
