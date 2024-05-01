import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class MunroPictureService {
  static Future getMunroPictures(BuildContext context, {required String munroId, int count = 18}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.loading;
      List<MunroPicture> munroPictures = await MunroPicturesDatabase.readMunroPictures(
        context,
        munroId: munroId,
        lastPictureId: null,
        count: count,
      );

      munroDetailState.setMunroPictures = munroPictures;
      munroDetailState.setGalleryStatus = MunroDetailStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroDetailState.setError =
          Error(message: "There was an issue loading pictures for this munro. Please try again.");
    }
  }

  static Future paginateMunroPictures(BuildContext context, {required String munroId}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.paginating;

      // Find last user ID
      String? lastMunroPictureId;
      if (munroDetailState.munroPictures.isNotEmpty) {
        lastMunroPictureId = munroDetailState.munroPictures.last.uid;
      }

      // Add munroPictures from database
      List<MunroPicture> newMunroPictures = await MunroPicturesDatabase.readMunroPictures(
        context,
        munroId: munroId,
        lastPictureId: lastMunroPictureId,
      );

      munroDetailState.addMunroPictures = newMunroPictures;
      munroDetailState.setGalleryStatus = MunroDetailStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroDetailState.setError =
          Error(message: "There was an issue loading pictures for this munro. Please try again.");
    }
  }
}
