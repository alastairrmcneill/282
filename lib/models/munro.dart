import 'package:cloud_firestore/cloud_firestore.dart';

class Munro {
  final String id;
  final String name;
  final String? extra;
  final String area;
  final int meters;
  final String section;
  final String region;
  final int feet;
  final double lat;
  final double lng;
  final String link;
  final String description;
  final String pictureURL;
  bool summited;
  DateTime? summitedDate;
  bool saved;
  double? averageRating;
  int? reviewCount;

  Munro({
    required this.id,
    required this.name,
    required this.extra,
    required this.area,
    required this.meters,
    required this.section,
    required this.region,
    required this.feet,
    required this.lat,
    required this.lng,
    required this.link,
    required this.description,
    required this.pictureURL,
    required this.summited,
    this.summitedDate,
    this.saved = false,
    this.averageRating,
    this.reviewCount,
  });

  Map<String, dynamic> toJSON() {
    return {
      MunroFields.id: id,
      MunroFields.name: name,
      MunroFields.extra: extra,
      MunroFields.area: area,
      MunroFields.maters: meters,
      MunroFields.section: section,
      MunroFields.region: region,
      MunroFields.feet: feet,
      MunroFields.lat: lat,
      MunroFields.lng: lng,
      MunroFields.link: link,
      MunroFields.description: description,
      MunroFields.pictureURL: pictureURL,
      MunroFields.summited: summited,
      MunroFields.summitedDate: summitedDate,
      MunroFields.saved: saved,
      MunroFields.averageRating: averageRating,
      MunroFields.reviewCount: reviewCount,
    };
  }

  static Munro fromJSON(Map<String, dynamic> json) {
    return Munro(
      id: json[MunroFields.id] as String,
      name: json[MunroFields.name] as String,
      extra: json[MunroFields.extra] as String,
      area: json[MunroFields.area] as String,
      meters: json[MunroFields.maters] as int,
      section: json[MunroFields.section] as String,
      region: json[MunroFields.region] as String,
      feet: json[MunroFields.feet] as int,
      lat: json[MunroFields.lat] as double,
      lng: json[MunroFields.lng] as double,
      link: json[MunroFields.link] as String,
      description: json[MunroFields.description] as String,
      pictureURL: json[MunroFields.pictureURL] as String,
      summited: (json[MunroFields.summited] as bool),
      summitedDate:
          json[MunroFields.summitedDate] != null ? (json[MunroFields.summitedDate] as Timestamp).toDate() : null,
      saved: json[MunroFields.saved] as bool? ?? false,
      averageRating: json[MunroFields.averageRating] as double?,
      reviewCount: json[MunroFields.reviewCount] as int?,
    );
  }

  Munro copy({
    String? id,
    String? name,
    String? extra,
    String? area,
    int? meters,
    String? section,
    String? region,
    int? feet,
    double? lat,
    double? lng,
    String? link,
    String? description,
    String? pictureURL,
    bool? summited,
    DateTime? summitedDate,
    bool? saved,
    double? averageRating,
    int? reviewCount,
  }) {
    return Munro(
      id: id ?? this.id,
      name: name ?? this.name,
      extra: extra ?? this.extra,
      area: area ?? this.area,
      meters: meters ?? this.meters,
      section: section ?? this.section,
      region: region ?? this.region,
      feet: feet ?? this.feet,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      link: link ?? this.link,
      description: description ?? this.description,
      pictureURL: pictureURL ?? this.pictureURL,
      summited: summited ?? this.summited,
      summitedDate: summitedDate ?? this.summitedDate,
      saved: saved ?? this.saved,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}

class MunroFields {
  static String id = "id";
  static String name = "name";
  static String extra = "extra";
  static String area = "area";
  static String maters = "meters";
  static String section = "section";
  static String region = "region";
  static String feet = "feet";
  static String lat = "lat";
  static String lng = "lng";
  static String link = "link";
  static String description = "description";
  static String pictureURL = "pictureURL";
  static String summited = "summited";
  static String summitedDate = "summitedDate";
  static String saved = "saved";
  static String averageRating = "averageRating";
  static String reviewCount = "reviewCount";
}
