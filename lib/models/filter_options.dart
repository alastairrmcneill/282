class FilterOptions {
  List<String> completed = [];
  List<String> areas = [];

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'areas': areas,
    };
  }
}
