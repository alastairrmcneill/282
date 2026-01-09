import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'profile_gallery_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  MunroPicturesRepository,
  UserState,
  Logger,
])
void main() {
  late MockMunroPicturesRepository mockMunroPicturesRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late ProfileGalleryState profileGalleryState;

  late List<MunroPicture> samplePhotos;

  setUp(() {
    // Sample munro picture data for testing
    samplePhotos = [
      MunroPicture(
        uid: 'photo1',
        munroId: 1,
        authorId: 'user1',
        imageUrl: 'https://example.com/photo1.jpg',
        dateTime: DateTime(2024, 1, 1),
        postId: 'post1',
        privacy: Privacy.public,
      ),
      MunroPicture(
        uid: 'photo2',
        munroId: 2,
        authorId: 'user1',
        imageUrl: 'https://example.com/photo2.jpg',
        dateTime: DateTime(2024, 1, 2),
        postId: 'post2',
        privacy: Privacy.public,
      ),
      MunroPicture(
        uid: 'photo3',
        munroId: 3,
        authorId: 'user1',
        imageUrl: 'https://example.com/photo3.jpg',
        dateTime: DateTime(2024, 1, 3),
        postId: 'post3',
        privacy: Privacy.public,
      ),
    ];

    mockMunroPicturesRepository = MockMunroPicturesRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    profileGalleryState = ProfileGalleryState(
      mockMunroPicturesRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);
  });

  group('ProfileGalleryState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(profileGalleryState.status, ProfileGalleryStatus.initial);
        expect(profileGalleryState.error, isA<Error>());
        expect(profileGalleryState.photos, isEmpty);
      });
    });

    group('getMunroPictures', () {
      test('should load photos successfully with default count', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
        expect(profileGalleryState.photos, samplePhotos);
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load photos successfully with custom count', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1', count: 30);

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
        expect(profileGalleryState.photos, samplePhotos);
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: [],
          offset: 0,
          count: 30,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenThrow(Exception('Network error'));

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.error);
        expect(profileGalleryState.error.message,
            'There was an issue loading pictures for this profile. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return samplePhotos;
        });

        // Act
        final future = profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert intermediate state
        expect(profileGalleryState.status, ProfileGalleryStatus.loading);

        // Wait for completion
        await future;
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
      });
    });

    group('paginateMunroPictures', () {
      test('should paginate photos successfully', () async {
        // Set initial photos - use a copy to avoid mutating samplePhotos
        profileGalleryState.setStatus = ProfileGalleryStatus.loaded;
        // Manually set photos by triggering a successful load first
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Arrange
        final additionalPhotos = [
          MunroPicture(
            uid: 'photo4',
            munroId: 4,
            authorId: 'user1',
            imageUrl: 'https://example.com/photo4.jpg',
            dateTime: DateTime(2024, 1, 4),
            postId: 'post4',
            privacy: Privacy.public,
          ),
        ];

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => additionalPhotos);

        // Act
        final result = await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
        expect(profileGalleryState.photos.length, 4);
        expect(profileGalleryState.photos.last.uid, 'photo4');
        expect(result, additionalPhotos);
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: [],
          offset: 3,
          count: 18,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: blockedUsers,
          offset: 3,
          count: 18,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Store initial photo count
        final initialCount = profileGalleryState.photos.length;

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenThrow(Exception('Pagination error'));

        // Act
        final result = await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.error);
        expect(profileGalleryState.error.message,
            'There was an issue loading pictures for this profile. Please try again.');
        // Original photos should remain unchanged
        expect(profileGalleryState.photos.length, initialCount);
        expect(result, isEmpty);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert intermediate state
        expect(profileGalleryState.status, ProfileGalleryStatus.paginating);

        // Wait for completion
        await future;
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
      });

      test('should return empty list when no more photos available', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        final result = await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        expect(result, isEmpty);
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        profileGalleryState.setStatus = ProfileGalleryStatus.loading;
        expect(profileGalleryState.status, ProfileGalleryStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        profileGalleryState.setError = error;

        expect(profileGalleryState.status, ProfileGalleryStatus.error);
        expect(profileGalleryState.error, error);
      });
    });

    group('Edge Cases', () {
      test('should handle empty photos list on initial load', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
        expect(profileGalleryState.photos, isEmpty);
      });

      test('should handle empty photos list on pagination', () async {
        // Arrange - start with empty list
        expect(profileGalleryState.photos, isEmpty);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        // Act
        final result = await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.photos, samplePhotos);
        expect(result, samplePhotos);
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.status, ProfileGalleryStatus.loaded);
        expect(profileGalleryState.photos, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user1',
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle null dateTime in MunroPicture', () async {
        // Arrange
        final photosWithNullDate = [
          MunroPicture(
            uid: 'photo1',
            munroId: 1,
            authorId: 'user1',
            imageUrl: 'https://example.com/photo1.jpg',
            dateTime: null,
            postId: 'post1',
            privacy: Privacy.public,
          ),
        ];
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => photosWithNullDate);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.photos.first.dateTime, isNull);
      });

      test('should handle null uid in MunroPicture', () async {
        // Arrange
        final photosWithNullUid = [
          MunroPicture(
            uid: null,
            munroId: 1,
            authorId: 'user1',
            imageUrl: 'https://example.com/photo1.jpg',
            dateTime: DateTime(2024, 1, 1),
            postId: 'post1',
            privacy: Privacy.public,
          ),
        ];
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => photosWithNullUid);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(profileGalleryState.photos.first.uid, isNull);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading photos', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        bool notified = false;
        profileGalleryState.addListener(() => notified = true);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating photos', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        profileGalleryState.addListener(() => notified = true);

        // Act
        await profileGalleryState.paginateMunroPictures(profileId: 'user1');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        profileGalleryState.addListener(() => notified = true);

        profileGalleryState.setStatus = ProfileGalleryStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        profileGalleryState.addListener(() => notified = true);

        profileGalleryState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners multiple times during load operation', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: anyNamed('profileId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => samplePhotos);

        int notificationCount = 0;
        profileGalleryState.addListener(() => notificationCount++);

        // Act
        await profileGalleryState.getMunroPictures(profileId: 'user1');

        // Assert - should notify at least twice (loading + loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });
  });
}
