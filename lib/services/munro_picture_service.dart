import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class MunroPictureService {
  static Future getMunroPictures(BuildContext context, {required int munroId, int count = 18}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.loading;
      List<String> blockedUsers = userState.blockedUsers;
      List<MunroPicture> munroPictures = [];

      munroPictures = await MunroPicturesDatabase.readMunroPictures(
        context,
        munroId: munroId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
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

  static Future<List<MunroPicture>> paginateMunroPictures(BuildContext context, {required int munroId}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.paginating;
      List<String> blockedUsers = userState.blockedUsers;
      List<MunroPicture> newMunroPictures = [];

      newMunroPictures = await MunroPicturesDatabase.readMunroPictures(
        context,
        munroId: munroId,
        excludedAuthorIds: blockedUsers,
        offset: munroDetailState.munroPictures.length,
      );

      munroDetailState.addMunroPictures = newMunroPictures;
      munroDetailState.setGalleryStatus = MunroDetailStatus.loaded;
      return newMunroPictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroDetailState.setError = Error(
        message: "There was an issue loading pictures for this munro. Please try again.",
      );
      return [];
    }
  }

  static Future getProfilePictures(BuildContext context, {required String profileId, int count = 18}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      profileState.setPhotoStatus = ProfilePhotoStatus.loading;
      List<String> blockedUsers = userState.blockedUsers;
      List<MunroPicture> profilePictures = [];

      profilePictures = await MunroPicturesDatabase.readProfilePictures(
        context,
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
        count: count,
      );

      profileState.setProfilePhotos = profilePictures;
      profileState.setPhotoStatus = ProfilePhotoStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
    }
  }

  static Future<List<MunroPicture>> paginateProfilePictures(BuildContext context, {required String profileId}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      profileState.setPhotoStatus = ProfilePhotoStatus.loading;
      List<String> blockedUsers = userState.blockedUsers;
      List<MunroPicture> profilePictures = [];

      profilePictures = await MunroPicturesDatabase.readProfilePictures(
        context,
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: profileState.profilePhotos.length,
      );

      profileState.addProfilePhotos = profilePictures;
      profileState.setPhotoStatus = ProfilePhotoStatus.loaded;
      return profilePictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
      return [];
    }
  }
}
