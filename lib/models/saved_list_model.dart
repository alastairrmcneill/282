class SavedList {
  final String? uid;
  final String name;
  final String userId;
  final List<String> munroIds;

  SavedList({
    required this.uid,
    required this.name,
    required this.userId,
    required this.munroIds,
  });

  Map<String, dynamic> toJSON() {
    return {
      SavedListFields.uid: uid,
      SavedListFields.name: name,
      SavedListFields.userId: userId,
      SavedListFields.munroIds: munroIds,
    };
  }

  static SavedList fromJSON(Map<String, dynamic> json) {
    return SavedList(
      uid: json[SavedListFields.uid] as String?,
      name: json[SavedListFields.name] as String,
      userId: json[SavedListFields.userId] as String,
      munroIds: List<String>.from(json[SavedListFields.munroIds] as List<dynamic>),
    );
  }

  SavedList copy({
    String? uid,
    String? name,
    String? userId,
    List<String>? munroIds,
  }) {
    return SavedList(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      munroIds: munroIds ?? this.munroIds,
    );
  }

  @override
  String toString() {
    return 'SavedList{${SavedListFields.uid}: $uid, ${SavedListFields.name}: $name, ${SavedListFields.userId}: $userId, ${SavedListFields.munroIds}: $munroIds}';
  }
}

class SavedListFields {
  static const String uid = 'uid';
  static const String name = 'name';
  static const String userId = 'userId';
  static const String munroIds = 'munroIds';
}
