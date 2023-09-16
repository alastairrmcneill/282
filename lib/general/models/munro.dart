class Munro {
  final int id;
  final String name;
  final String? parent;
  final String area;
  final int meters;
  final String section;
  final String region;
  final int feet;
  final double lat;
  final double lng;
  final String link;

  Munro({
    required this.id,
    required this.name,
    required this.parent,
    required this.area,
    required this.meters,
    required this.section,
    required this.region,
    required this.feet,
    required this.lat,
    required this.lng,
    required this.link,
  });

  Map<String, dynamic> toJSON() {
    return {
      MunroFields.id: id,
      MunroFields.name: name,
      MunroFields.parent: parent,
      MunroFields.area: area,
      MunroFields.maters: meters,
      MunroFields.section: section,
      MunroFields.region: region,
      MunroFields.feet: feet,
      MunroFields.lat: lat,
      MunroFields.lng: lng,
      MunroFields.link: link,
    };
  }

  static Munro fromJSON(Map<String, dynamic> json) {
    return Munro(
      id: json[MunroFields.id] as int,
      name: json[MunroFields.name] as String,
      parent: json[MunroFields.parent] as String,
      area: json[MunroFields.area] as String,
      meters: json[MunroFields.maters] as int,
      section: json[MunroFields.section] as String,
      region: json[MunroFields.region] as String,
      feet: json[MunroFields.feet] as int,
      lat: json[MunroFields.lat] as double,
      lng: json[MunroFields.lng] as double,
      link: json[MunroFields.link] as String,
    );
  }

  Munro copy({
    int? id,
    String? name,
    String? parent,
    String? area,
    int? meters,
    String? section,
    String? region,
    int? feet,
    double? lat,
    double? lng,
    String? link,
  }) {
    return Munro(
      id: id ?? this.id,
      name: name ?? this.name,
      parent: parent ?? this.parent,
      area: area ?? this.area,
      meters: meters ?? this.meters,
      section: section ?? this.section,
      region: region ?? this.region,
      feet: feet ?? this.feet,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      link: link ?? this.link,
    );
  }
}

class MunroFields {
  static String id = "id";
  static String name = "name";
  static String parent = "parent";
  static String area = "area";
  static String maters = "meters";
  static String section = "section";
  static String region = "region";
  static String feet = "feet";
  static String lat = "lat";
  static String lng = "lng";
  static String link = "link";
}
