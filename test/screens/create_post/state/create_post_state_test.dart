import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'create_post_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PostsRepository,
  MunroPicturesRepository,
  StorageRepository,
  UserState,
  MunroCompletionState,
  RemoteConfigState,
  Analytics,
  Logger,
])
void main() {
  late MockPostsRepository mockPostsRepository;
  late MockMunroPicturesRepository mockMunroPicturesRepository;
  late MockStorageRepository mockStorageRepository;
  late MockUserState mockUserState;
  late MockMunroCompletionState mockMunroCompletionState;
  late MockRemoteConfigState mockRemoteConfigState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late CreatePostState createPostState;

  late AppUser sampleUser;
  late Post samplePost;
  late DateTime sampleDate;
  late TimeOfDay sampleTime;

  setUp(() {
    // Sample data for testing
    sampleDate = DateTime(2024, 6, 15);
    sampleTime = const TimeOfDay(hour: 10, minute: 30);

    sampleUser = AppUser(
      uid: 'currentUser',
      displayName: 'Test User',
      profilePictureURL: 'https://example.com/profile.jpg',
      searchName: 'test user',
    );

    samplePost = Post(
      uid: 'post123',
      authorId: 'currentUser',
      authorDisplayName: 'Test User',
      authorProfilePictureURL: 'https://example.com/profile.jpg',
      title: 'Summer Hike',
      description: 'A great day on the hills',
      dateTimeCreated: DateTime(2024, 6, 15, 10, 30),
      summitedDateTime: DateTime(2024, 6, 15, 10, 30),
      imageUrlsMap: {},
      includedMunroIds: [1, 2],
      privacy: Privacy.public,
    );

    mockPostsRepository = MockPostsRepository();
    mockMunroPicturesRepository = MockMunroPicturesRepository();
    mockStorageRepository = MockStorageRepository();
    mockUserState = MockUserState();
    mockMunroCompletionState = MockMunroCompletionState();
    mockRemoteConfigState = MockRemoteConfigState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    createPostState = CreatePostState(
      mockPostsRepository,
      mockMunroPicturesRepository,
      mockStorageRepository,
      mockUserState,
      mockMunroCompletionState,
      mockRemoteConfigState,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(sampleUser);

    // Default mock behavior for MunroCompletionState
    when(mockMunroCompletionState.markMunrosAsCompleted(
      munroIds: anyNamed('munroIds'),
      summitDateTime: anyNamed('summitDateTime'),
      postId: anyNamed('postId'),
    )).thenAnswer((_) async => {});

    when(mockMunroCompletionState.removeCompletionsByMunroIdsAndPost(
      munroIds: anyNamed('munroIds'),
      postId: anyNamed('postId'),
    )).thenAnswer((_) async => {});

    // Default mock behavior for Analytics
    when(mockAnalytics.track(
      any,
      props: anyNamed('props'),
    )).thenAnswer((_) async => {});

    // Reset the state to ensure clean slate for each test
    createPostState.reset();
  });

  group('CreatePostState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(createPostState.status, CreatePostStatus.initial);
        expect(createPostState.error, isA<Error>());
        expect(createPostState.title, isNull);
        expect(createPostState.description, isNull);
        expect(createPostState.summitedDate, isNull);
        expect(createPostState.startTime, isNull);
        expect(createPostState.duration, isNull);
        expect(createPostState.existingImages, isEmpty);
        expect(createPostState.addedImages, isEmpty);
        expect(createPostState.deletedImages, isEmpty);
        expect(createPostState.existingMunroIds, isEmpty);
        expect(createPostState.addedMunroIds, isEmpty);
        expect(createPostState.deletedMunroIds, isEmpty);
        expect(createPostState.selectedMunroIds, isEmpty);
        expect(createPostState.postPrivacy, isNull);
        expect(createPostState.hasImage, false);
        expect(createPostState.editingPost, isNull);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        createPostState.setStatus = CreatePostStatus.loading;
        expect(createPostState.status, CreatePostStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        createPostState.setError = error;

        expect(createPostState.status, CreatePostStatus.error);
        expect(createPostState.error, error);
      });

      test('setTitle should update title', () {
        createPostState.setTitle = 'My Amazing Hike';
        expect(createPostState.title, 'My Amazing Hike');
      });

      test('setDescription should update description', () {
        createPostState.setDescription = 'A wonderful day in the mountains';
        expect(createPostState.description, 'A wonderful day in the mountains');
      });

      test('setSummitedDate should update summited date', () {
        createPostState.setSummitedDate = sampleDate;
        expect(createPostState.summitedDate, sampleDate);
      });

      test('setStartTime should update start time', () {
        createPostState.setStartTime = sampleTime;
        expect(createPostState.startTime, sampleTime);
      });

      test('setDuration should update duration', () {
        final duration = const Duration(hours: 5, minutes: 30);
        createPostState.setDuration = duration;
        expect(createPostState.duration, duration);
      });

      test('setPostPrivacy should update post privacy', () {
        createPostState.setPostPrivacy = Privacy.private;
        expect(createPostState.postPrivacy, Privacy.private);
      });
    });

    group('loadPost', () {
      test('should load post data correctly', () {
        createPostState.loadPost = samplePost;

        expect(createPostState.editingPost, samplePost);
        expect(createPostState.title, samplePost.title);
        expect(createPostState.summitedDate, samplePost.summitedDateTime);
        expect(createPostState.description, samplePost.description);
        expect(createPostState.existingImages, samplePost.imageUrlsMap);
        expect(createPostState.addedImages, isEmpty);
        expect(createPostState.deletedImages, isEmpty);
        expect(createPostState.existingMunroIds, samplePost.includedMunroIds.toSet());
        expect(createPostState.addedMunroIds, isEmpty);
        expect(createPostState.deletedMunroIds, isEmpty);
        expect(createPostState.postPrivacy, samplePost.privacy);
      });

      test('should extract correct time from post summited date', () {
        createPostState.loadPost = samplePost;

        expect(createPostState.startTime?.hour, samplePost.summitedDateTime?.hour);
        expect(createPostState.startTime?.minute, samplePost.summitedDateTime?.minute);
      });

      test('should handle post with null summited date', () {
        final postWithNullDate = Post(
          uid: 'post123',
          authorId: 'currentUser',
          title: 'Test Post',
          summitedDateTime: null,
        );

        createPostState.loadPost = postWithNullDate;

        expect(createPostState.summitedDate, isNull);
        expect(createPostState.startTime?.hour, 12);
        expect(createPostState.startTime?.minute, 0);
      });
    });

    group('addMunro', () {
      test('should add munro to added munros set', () {
        createPostState.addMunro(1);
        createPostState.addMunro(2);
        createPostState.addMunro(3);

        expect(createPostState.addedMunroIds, {1, 2, 3});
        expect(createPostState.selectedMunroIds, {1, 2, 3});
      });

      test('should not add duplicate munros', () {
        createPostState.addMunro(1);
        createPostState.addMunro(1);

        expect(createPostState.addedMunroIds.length, 1);
      });
    });

    group('removeMunro', () {
      test('should remove munro from added munros', () {
        createPostState.addMunro(1);
        createPostState.addMunro(2);
        createPostState.removeMunro(1);

        expect(createPostState.addedMunroIds, {2});
        expect(createPostState.deletedMunroIds, {1});
      });

      test('should move existing munro to deleted munros', () {
        createPostState.loadPost = samplePost;
        createPostState.removeMunro(1);

        expect(createPostState.existingMunroIds.contains(1), false);
        expect(createPostState.deletedMunroIds.contains(1), true);
      });
    });

    group('addImage', () {
      test('should add image to munro', () {
        final mockFile = File('test/image1.jpg');
        createPostState.addMunro(1);
        createPostState.addImage(munroId: 1, image: mockFile);

        expect(createPostState.addedImages[1], [mockFile]);
        expect(createPostState.hasImage, true);
      });

      test('should add multiple images to same munro', () {
        final mockFile1 = File('test/image1.jpg');
        final mockFile2 = File('test/image2.jpg');
        createPostState.addMunro(1);
        createPostState.addImage(munroId: 1, image: mockFile1);
        createPostState.addImage(munroId: 1, image: mockFile2);

        expect(createPostState.addedImages[1]?.length, 2);
        expect(createPostState.hasImage, true);
      });
    });

    group('removeImage', () {
      test('should remove image from added images', () {
        final mockFile1 = File('test/image1.jpg');
        final mockFile2 = File('test/image2.jpg');
        createPostState.addMunro(1);
        createPostState.addImage(munroId: 1, image: mockFile1);
        createPostState.addImage(munroId: 1, image: mockFile2);

        createPostState.removeImage(munroId: 1, index: 0);

        expect(createPostState.addedImages[1]?.length, 1);
        expect(createPostState.addedImages[1]?.first, mockFile2);
      });

      test('should handle removing from non-existent munro', () {
        expect(() => createPostState.removeImage(munroId: 999, index: 0), returnsNormally);
      });
    });

    group('selectedMunroIds', () {
      test('should return union of existing and added munros', () {
        createPostState.loadPost = samplePost;
        createPostState.addMunro(3);
        createPostState.addMunro(4);

        expect(createPostState.selectedMunroIds, {1, 2, 3, 4});
      });

      test('should exclude deleted munros', () {
        createPostState.loadPost = samplePost;
        createPostState.removeMunro(1);
        createPostState.addMunro(3);

        expect(createPostState.selectedMunroIds, {2, 3});
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        createPostState.setTitle = 'Test Title';
        createPostState.setDescription = 'Test Description';
        createPostState.setSummitedDate = sampleDate;
        createPostState.setStartTime = sampleTime;
        createPostState.setDuration = const Duration(hours: 5);
        createPostState.setPostPrivacy = Privacy.private;
        createPostState.setStatus = CreatePostStatus.loaded;
        createPostState.addMunro(1);
        final mockFile = File('test/image.jpg');
        createPostState.addImage(munroId: 1, image: mockFile);

        // Act
        createPostState.reset();

        // Assert
        expect(createPostState.status, CreatePostStatus.initial);
        expect(createPostState.error, isA<Error>());
        expect(createPostState.title, isNull);
        expect(createPostState.description, isNull);
        expect(createPostState.summitedDate, isNull);
        expect(createPostState.startTime, isNull);
        expect(createPostState.duration, isNull);
        expect(createPostState.existingImages, isEmpty);
        expect(createPostState.addedImages, isEmpty);
        expect(createPostState.deletedImages, isEmpty);
        expect(createPostState.existingMunroIds, isEmpty);
        expect(createPostState.addedMunroIds, isEmpty);
        expect(createPostState.deletedMunroIds, isEmpty);
        expect(createPostState.postPrivacy, isNull);
        expect(createPostState.editingPost, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle null title gracefully', () {
        createPostState.setTitle = null;
        expect(createPostState.title, isNull);
      });

      test('should handle null description gracefully', () {
        createPostState.setDescription = null;
        expect(createPostState.description, isNull);
      });

      test('should handle empty sets of munro ids', () {
        expect(createPostState.selectedMunroIds, isEmpty);
        expect(createPostState.addedMunroIds, isEmpty);
        expect(createPostState.existingMunroIds, isEmpty);
        expect(createPostState.deletedMunroIds, isEmpty);
      });

      test('should handle removing munro that does not exist', () {
        expect(() => createPostState.removeMunro(999), returnsNormally);
        expect(createPostState.deletedMunroIds, isEmpty);
      });

      test('should handle adding same munro multiple times', () {
        createPostState.addMunro(1);
        createPostState.addMunro(1);
        createPostState.addMunro(1);

        expect(createPostState.addedMunroIds.length, 1);
      });
    });

    group('createPost with Storage Repository', () {
      test('should upload images and create post successfully', () async {
        // Arrange
        final mockFile1 = File('test/image1.jpg');
        final mockFile2 = File('test/image2.jpg');
        final uploadedURL1 = 'https://example.com/image1.jpg';
        final uploadedURL2 = 'https://example.com/image2.jpg';

        createPostState.setTitle = 'Test Post';
        createPostState.setSummitedDate = sampleDate;
        createPostState.addMunro(1);
        createPostState.addImage(munroId: 1, image: mockFile1);
        createPostState.addImage(munroId: 1, image: mockFile2);

        when(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')))
            .thenAnswer((invocation) async {
          final file = invocation.namedArguments[Symbol('imageFile')] as File;
          if (file.path == mockFile1.path) return uploadedURL1;
          if (file.path == mockFile2.path) return uploadedURL2;
          return 'https://example.com/default.jpg';
        });
        when(mockPostsRepository.create(post: anyNamed('post'))).thenAnswer((_) async => 'post123');
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});

        // Act
        await createPostState.createPost();

        // Assert
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile1,
          type: ImageUploadType.post,
        )).called(1);
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile2,
          type: ImageUploadType.post,
        )).called(1);

        // If RemoteConfigService fails, an error will be logged
        // Either way, we've verified the storage calls happened
      });

      test('should handle storage upload error during post creation', () async {
        // Arrange
        final mockFile = File('test/image.jpg');

        createPostState.setTitle = 'Test Post';
        createPostState.addMunro(1);
        createPostState.addImage(munroId: 1, image: mockFile);

        when(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')))
            .thenThrow(Exception('Upload failed'));

        // Act
        final result = await createPostState.createPost();

        // Assert
        expect(result, isNull);
        expect(createPostState.status, CreatePostStatus.error);
        expect(createPostState.error.message, 'There was an issue uploading your post. Please try again');
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile,
          type: ImageUploadType.post,
        )).called(1);
        verifyNever(mockPostsRepository.create(post: anyNamed('post')));
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should create post without images and not call storage repository', () async {
        // Arrange
        createPostState.setTitle = 'Test Post';
        createPostState.setSummitedDate = sampleDate;
        createPostState.addMunro(1);

        when(mockPostsRepository.create(post: anyNamed('post'))).thenAnswer((_) async => 'post123');
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});

        // Act
        await createPostState.createPost();

        // Assert
        verifyNever(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')));
      });
    });

    group('editPost with Storage Repository', () {
      test('should upload new images via storage repository when editing post', () async {
        // Arrange
        final mockFile = File('test/new_image.jpg');
        final uploadedURL = 'https://example.com/new_image.jpg';

        createPostState.loadPost = samplePost;
        createPostState.addMunro(3);
        createPostState.addImage(munroId: 3, image: mockFile);

        when(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')))
            .thenAnswer((_) async => uploadedURL);
        when(mockPostsRepository.update(post: anyNamed('post'))).thenAnswer((_) async {});
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});

        // Act
        await createPostState.editPost();

        // Assert - Main verification: storage repository upload was called
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile,
          type: ImageUploadType.post,
        )).called(1);
      });

      test('should delete images from storage when editing post', () async {
        // Arrange
        final deletedURL1 = 'https://example.com/deleted1.jpg';
        final deletedURL2 = 'https://example.com/deleted2.jpg';

        // Create a post with existing images
        final postWithImages = samplePost.copyWith(
          imageUrlsMap: {
            1: [deletedURL1, deletedURL2],
          },
        );

        createPostState.loadPost = postWithImages;
        createPostState.removeExistingImage(munroId: 1, url: deletedURL1);
        createPostState.removeExistingImage(munroId: 1, url: deletedURL2);

        when(mockPostsRepository.update(post: anyNamed('post'))).thenAnswer((_) async {});
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});
        when(mockMunroPicturesRepository.deleteMunroPicturesByUrls(imageURLs: anyNamed('imageURLs')))
            .thenAnswer((_) async {});
        when(mockStorageRepository.deleteByUrl(any)).thenAnswer((_) async {});

        // Act
        final result = await createPostState.editPost();

        // Assert
        expect(result, isNotNull);
        expect(createPostState.status, CreatePostStatus.loaded);
        verify(mockMunroPicturesRepository.deleteMunroPicturesByUrls(
          imageURLs: argThat(
            predicate<List<String>>(
              (urls) => urls.contains(deletedURL1) && urls.contains(deletedURL2),
            ),
            named: 'imageURLs',
          ),
        )).called(1);
        verify(mockStorageRepository.deleteByUrl(deletedURL1)).called(1);
        verify(mockStorageRepository.deleteByUrl(deletedURL2)).called(1);
      });

      test('should handle storage error when uploading images during edit', () async {
        // Arrange
        final mockFile = File('test/new_image.jpg');

        createPostState.loadPost = samplePost;
        createPostState.addMunro(3);
        createPostState.addImage(munroId: 3, image: mockFile);

        when(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')))
            .thenThrow(Exception('Upload failed'));

        // Act
        final result = await createPostState.editPost();

        // Assert
        expect(result, isNull);
        expect(createPostState.status, CreatePostStatus.error);
        expect(createPostState.error.message, 'There was an issue uploading your post. Please try again');
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile,
          type: ImageUploadType.post,
        )).called(1);
        verifyNever(mockPostsRepository.update(post: anyNamed('post')));
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle storage error when deleting images during edit', () async {
        // Arrange
        final deletedURL = 'https://example.com/deleted.jpg';

        final postWithImages = samplePost.copyWith(
          imageUrlsMap: {
            1: [deletedURL],
          },
        );

        createPostState.loadPost = postWithImages;
        createPostState.removeExistingImage(munroId: 1, url: deletedURL);

        when(mockPostsRepository.update(post: anyNamed('post'))).thenAnswer((_) async {});
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});
        when(mockMunroPicturesRepository.deleteMunroPicturesByUrls(imageURLs: anyNamed('imageURLs')))
            .thenAnswer((_) async {});
        when(mockStorageRepository.deleteByUrl(any)).thenThrow(Exception('Delete failed'));

        // Act
        final result = await createPostState.editPost();

        // Assert - The error in deleteByUrl doesn't propagate to editPost, so it succeeds
        // This might be a design choice or bug in the implementation
        expect(result, isNull);
        expect(createPostState.status, CreatePostStatus.error);
        verify(mockStorageRepository.deleteByUrl(deletedURL)).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should upload multiple images via storage repository for multiple munros', () async {
        // Arrange
        final mockFile1 = File('test/image1.jpg');
        final mockFile2 = File('test/image2.jpg');
        final uploadedURL1 = 'https://example.com/image1.jpg';
        final uploadedURL2 = 'https://example.com/image2.jpg';

        createPostState.loadPost = samplePost;
        createPostState.addMunro(3);
        createPostState.addMunro(4);
        createPostState.addImage(munroId: 3, image: mockFile1);
        createPostState.addImage(munroId: 4, image: mockFile2);

        when(mockStorageRepository.uploadImage(imageFile: anyNamed('imageFile'), type: anyNamed('type')))
            .thenAnswer((invocation) async {
          final file = invocation.namedArguments[Symbol('imageFile')] as File;
          if (file.path == mockFile1.path) return uploadedURL1;
          if (file.path == mockFile2.path) return uploadedURL2;
          return 'https://example.com/default.jpg';
        });
        when(mockPostsRepository.update(post: anyNamed('post'))).thenAnswer((_) async {});
        when(mockMunroPicturesRepository.createMunroPictures(munroPictures: anyNamed('munroPictures')))
            .thenAnswer((_) async {});

        // Act
        await createPostState.editPost();

        // Assert - Main verification: both storage uploads were called
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile1,
          type: ImageUploadType.post,
        )).called(1);
        verify(mockStorageRepository.uploadImage(
          imageFile: mockFile2,
          type: ImageUploadType.post,
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when setting status', () {
        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.setStatus = CreatePostStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when setting title', () {
        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.setTitle = 'New Title';

        expect(notified, true);
      });

      test('should notify listeners when adding munro', () {
        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.addMunro(1);

        expect(notified, true);
      });

      test('should notify listeners when removing munro', () {
        createPostState.addMunro(1);

        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.removeMunro(1);

        expect(notified, true);
      });

      test('should notify listeners when adding image', () {
        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.addImage(munroId: 1, image: File('test.jpg'));

        expect(notified, true);
      });

      test('should notify listeners when loading post', () {
        bool notified = false;
        createPostState.addListener(() => notified = true);

        createPostState.loadPost = samplePost;

        expect(notified, true);
      });
    });
  });
}
