class SavedList {
  final String? uid;
  final String name;
  final String userId;
  final DateTime? dateTimeCreated;
  final List<int> munroIds;

  SavedList({
    this.uid,
    required this.name,
    required this.userId,
    required this.munroIds,
    this.dateTimeCreated,
  });

  Map<String, dynamic> toJSON() {
    return {
      SavedListFields.name: name,
      SavedListFields.userId: userId,
    };
  }

  static SavedList fromJSON(Map<String, dynamic> json) {
    return SavedList(
        uid: json[SavedListFields.uid] as String?,
        name: json[SavedListFields.name] as String,
        userId: json[SavedListFields.userId] as String,
        munroIds: List<int>.from(json[SavedListFields.munroIds] as List<dynamic>? ?? []),
        dateTimeCreated: DateTime.parse(json[SavedListFields.dateTimeCreated] as String));
  }

  SavedList copy({
    String? uid,
    String? name,
    String? userId,
    List<int>? munroIds,
    DateTime? dateTimeCreated,
  }) {
    return SavedList(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      munroIds: munroIds ?? this.munroIds,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
    );
  }

  @override
  String toString() {
    return 'SavedList{${SavedListFields.uid}: $uid, ${SavedListFields.name}: $name, ${SavedListFields.userId}: $userId, ${SavedListFields.munroIds}: $munroIds}, ${SavedListFields.dateTimeCreated}: $dateTimeCreated}';
  }
}

class SavedListFields {
  static const String uid = 'id';
  static const String name = 'name';
  static const String userId = 'user_id';
  static const String munroIds = 'munro_ids';
  static const String dateTimeCreated = 'date_time_created';
}
