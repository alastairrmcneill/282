import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class MunroPictureService {
  static Future getMunroPictures(BuildContext context, {required String munroId, int count = 18}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.loading;
      List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];
      List<MunroPicture> munroPictures = [];

      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        munroPictures = await MunroPicturesDatabaseSupabase.readMunroPictures(
          context,
          munroId: munroId,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: count,
        );
      } else {
        munroPictures = await MunroPicturesDatabase.readMunroPictures(
          context,
          munroId: munroId,
          lastPictureId: null,
          count: count,
        );

        // Filter pictures from blocked users
        munroPictures = munroPictures.where((munroPicture) => !blockedUsers.contains(munroPicture.authorId)).toList();
      }

      munroDetailState.setMunroPictures = munroPictures;
      munroDetailState.setGalleryStatus = MunroDetailStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroDetailState.setError =
          Error(message: "There was an issue loading pictures for this munro. Please try again.");
    }
  }

  static Future<List<MunroPicture>> paginateMunroPictures(BuildContext context, {required String munroId}) async {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      munroDetailState.setGalleryStatus = MunroDetailStatus.paginating;
      List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];
      List<MunroPicture> newMunroPictures = [];

      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        newMunroPictures = await MunroPicturesDatabaseSupabase.readMunroPictures(
          context,
          munroId: munroId,
          excludedAuthorIds: blockedUsers,
          offset: munroDetailState.munroPictures.length,
        );
      } else {
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

        // Filter pictures from blocked users
        newMunroPictures =
            newMunroPictures.where((munroPicture) => !blockedUsers.contains(munroPicture.authorId)).toList();
      }

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
      List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];
      List<MunroPicture> profilePictures = [];

      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        profilePictures = await MunroPicturesDatabaseSupabase.readProfilePictures(
          context,
          profileId: profileId,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: count,
        );
      } else {
        profilePictures = await MunroPicturesDatabase.readProfilePictures(
          context,
          profileId: profileId,
          lastPictureId: null,
          count: count,
        );

        // Filter pictures from blocked users
        profilePictures =
            profilePictures.where((profilePicture) => !blockedUsers.contains(profilePicture.authorId)).toList();
      }

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
      List<String> blockedUsers = userState.currentUser?.blockedUsers ?? [];
      List<MunroPicture> profilePictures = [];

      if (RemoteConfigService.getBool(RCFields.useSupabase)) {
        profilePictures = await MunroPicturesDatabaseSupabase.readProfilePictures(
          context,
          profileId: profileId,
          excludedAuthorIds: blockedUsers,
          offset: profileState.profilePhotos.length,
        );
      } else {
        // Find last user ID
        String? lastMunroPictureId;
        if (profileState.profilePhotos.isNotEmpty) {
          lastMunroPictureId = profileState.profilePhotos.last.uid;
        }

        // Add munroPictures from database
        profilePictures = await MunroPicturesDatabase.readProfilePictures(
          context,
          profileId: profileId,
          lastPictureId: lastMunroPictureId,
        );

        // Filter pictures from blocked users
        profilePictures =
            profilePictures.where((profilePicture) => !blockedUsers.contains(profilePicture.authorId)).toList();
      }

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
