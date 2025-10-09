class SavedListMunro {
  final String? uid;
  final String savedListId;
  final int munroId;
  final DateTime? dateTimeAdded;

  SavedListMunro({
    this.uid,
    required this.savedListId,
    required this.munroId,
    this.dateTimeAdded,
  });

  Map<String, dynamic> toJSON() {
    return {
      SavedListMunroFields.savedListId: savedListId,
      SavedListMunroFields.munroId: munroId,
    };
  }

  static SavedListMunro fromJSON(Map<String, dynamic> json) {
    return SavedListMunro(
        uid: json[SavedListMunroFields.uid] as String?,
        savedListId: json[SavedListMunroFields.savedListId] as String,
        munroId: json[SavedListMunroFields.munroId] as int,
        dateTimeAdded: DateTime.parse(json[SavedListMunroFields.dateTimeAdded] as String));
  }

  SavedListMunro copy({
    String? uid,
    String? savedListId,
    int? munroId,
    DateTime? dateTimeAdded,
  }) {
    return SavedListMunro(
      uid: uid ?? this.uid,
      savedListId: savedListId ?? this.savedListId,
      munroId: munroId ?? this.munroId,
      dateTimeAdded: dateTimeAdded ?? this.dateTimeAdded,
    );
  }

  @override
  String toString() {
    return 'SavedListMunro{${SavedListMunroFields.uid}: $uid, ${SavedListMunroFields.savedListId}: $savedListId, ${SavedListMunroFields.munroId}: $munroId, ${SavedListMunroFields.dateTimeAdded}: $dateTimeAdded}';
  }
}

class SavedListMunroFields {
  static const String uid = 'id';
  static const String savedListId = 'saved_list_id';
  static const String munroId = 'munro_id';
  static const String dateTimeAdded = 'date_time_added';
}
