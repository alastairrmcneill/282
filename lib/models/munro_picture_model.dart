import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/models/models.dart';

class MunroPicture {
  final String? uid;
  final int munroId;
  final String authorId;
  final String imageUrl;
  final DateTime? dateTime;
  final String postId;
  final String privacy;

  MunroPicture({
    this.uid,
    required this.munroId,
    required this.authorId,
    required this.imageUrl,
    this.dateTime,
    required this.postId,
    required this.privacy,
  });

  static MunroPicture fromJSON(Map<String, dynamic> data) {
    final config = AppConfig.fromEnvironment();

    var imageUrl = data[MunroPictureFields.imageUrl] as String;
    if (config.imageProxyBaseUrl.isNotEmpty) {
      final uri = Uri.parse(imageUrl);
      final imagePath = uri.pathSegments.skip(4).join('/');
      imageUrl = '${config.imageProxyBaseUrl}/$imagePath';
    }

    return MunroPicture(
      uid: data[MunroPictureFields.uid] as String,
      munroId: data[MunroPictureFields.munroId] as int,
      authorId: data[MunroPictureFields.authorId] as String? ?? '',
      imageUrl: imageUrl,
      dateTime: DateTime.parse(data[MunroPictureFields.dateTime] as String),
      postId: data[MunroPictureFields.postId] as String,
      privacy: data[MunroPictureFields.privacy] as String? ?? Privacy.public,
    );
  }

  Map<String, dynamic> toJSON() => {
        MunroPictureFields.munroId: munroId,
        MunroPictureFields.authorId: authorId,
        MunroPictureFields.imageUrl: imageUrl,
        MunroPictureFields.postId: postId,
        MunroPictureFields.privacy: privacy,
      };
}

class MunroPictureFields {
  static const String uid = 'id';
  static const String munroId = 'munro_id';
  static const String authorId = 'author_id';
  static const String imageUrl = 'image_url';
  static const String dateTime = 'date_time_created';
  static const String postId = 'post_id';
  static const String privacy = 'privacy';
}
