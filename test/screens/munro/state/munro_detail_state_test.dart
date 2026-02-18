import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'munro_detail_state_test.mocks.dart';

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
  late MunroDetailState munroDetailState;

  late List<MunroPicture> sampleMunroPictures;

  setUp(() {
    // Sample munro picture data for testing
    sampleMunroPictures = [
      MunroPicture(
        uid: 'pic1',
        munroId: 1,
        authorId: 'user1',
        imageUrl: 'https://example.com/pic1.jpg',
        dateTime: DateTime(2024, 1, 1),
        postId: 'post1',
        privacy: Privacy.public,
      ),
      MunroPicture(
        uid: 'pic2',
        munroId: 1,
        authorId: 'user2',
        imageUrl: 'https://example.com/pic2.jpg',
        dateTime: DateTime(2024, 1, 2),
        postId: 'post2',
        privacy: Privacy.public,
      ),
      MunroPicture(
        uid: 'pic3',
        munroId: 1,
        authorId: 'user3',
        imageUrl: 'https://example.com/pic3.jpg',
        dateTime: null,
        postId: 'post3',
        privacy: Privacy.friends,
      ),
    ];

    mockMunroPicturesRepository = MockMunroPicturesRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    munroDetailState = MunroDetailState(
      mockMunroPicturesRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);
  });

  group('MunroDetailState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(munroDetailState.galleryStatus, MunroDetailStatus.initial);
        expect(munroDetailState.error, isA<Error>());
        expect(munroDetailState.munroPictures, isEmpty);
      });
    });

    group('loadMunroPictures', () {
      test('should load munro pictures successfully', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
        expect(munroDetailState.munroPictures, sampleMunroPictures);
        expect(munroDetailState.munroPictures.length, 3);
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load munro pictures with custom count', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1, count: 24);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
        expect(munroDetailState.munroPictures, sampleMunroPictures);
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
          count: 24,
        )).called(1);
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenThrow(Exception('Network error'));

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.error);
        expect(munroDetailState.error.message, 'There was an issue loading pictures for this munro. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleMunroPictures;
        });

        // Act
        final future = munroDetailState.loadMunroPictures(munroId: 1);

        // Assert intermediate state
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loading);

        // Wait for completion
        await future;
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
      });
    });

    group('paginateMunroPictures', () {
      test('should paginate munro pictures successfully', () async {
        // Set initial munro pictures - use a copy to avoid mutating sampleMunroPictures
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        // Arrange
        final additionalPictures = [
          MunroPicture(
            uid: 'pic4',
            munroId: 1,
            authorId: 'user4',
            imageUrl: 'https://example.com/pic4.jpg',
            dateTime: DateTime(2024, 1, 4),
            postId: 'post4',
            privacy: Privacy.public,
          ),
        ];

        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => additionalPictures);

        // Act
        final result = await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
        expect(munroDetailState.munroPictures.length, 4);
        expect(munroDetailState.munroPictures.last.uid, 'pic4');
        expect(result, munroDetailState.munroPictures);
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 3,
          count: 18,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should paginate with custom count', () async {
        // Arrange
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.paginateMunroPictures(munroId: 1, count: 24);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 3,
          count: 24,
        )).called(1);
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 3,
          count: 18,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial picture count
        final initialCount = munroDetailState.munroPictures.length;

        // Act
        final result = await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.error);
        expect(munroDetailState.error.message, 'There was an issue loading pictures for this munro. Please try again.');
        // Original pictures should remain unchanged
        expect(munroDetailState.munroPictures.length, initialCount);
        expect(result, isEmpty);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert intermediate state
        expect(munroDetailState.galleryStatus, MunroDetailStatus.paginating);

        // Wait for completion
        await future;
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
      });

      test('should return empty list on error', () async {
        // Arrange
        munroDetailState.setMunroPictures = List.from(sampleMunroPictures);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenThrow(Exception('Error'));

        // Act
        final result = await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('Setters', () {
      test('setGalleryStatus should update status', () {
        munroDetailState.setGalleryStatus = MunroDetailStatus.loading;
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        munroDetailState.setError = error;

        expect(munroDetailState.galleryStatus, MunroDetailStatus.error);
        expect(munroDetailState.error, error);
      });

      test('setMunroPictures should update munro pictures list', () {
        munroDetailState.setMunroPictures = sampleMunroPictures;

        expect(munroDetailState.munroPictures, sampleMunroPictures);
        expect(munroDetailState.munroPictures.length, 3);
      });

      test('addMunroPictures should append to existing munro pictures', () {
        munroDetailState.setMunroPictures = [sampleMunroPictures.first];

        munroDetailState.addMunroPictures = [sampleMunroPictures[1], sampleMunroPictures[2]];

        expect(munroDetailState.munroPictures.length, 3);
        expect(munroDetailState.munroPictures[0], sampleMunroPictures[0]);
        expect(munroDetailState.munroPictures[1], sampleMunroPictures[1]);
        expect(munroDetailState.munroPictures[2], sampleMunroPictures[2]);
      });
    });

    group('Edge Cases', () {
      test('should handle empty pictures list on pagination', () async {
        // Arrange - start with empty list
        expect(munroDetailState.munroPictures, isEmpty);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.munroPictures, sampleMunroPictures);
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle null dateTime in pictures', () {
        // Arrange
        final pictureWithNullDateTime = MunroPicture(
          uid: 'pic5',
          munroId: 1,
          authorId: 'user5',
          imageUrl: 'https://example.com/pic5.jpg',
          dateTime: null,
          postId: 'post5',
          privacy: Privacy.public,
        );

        // Act
        munroDetailState.setMunroPictures = [pictureWithNullDateTime];

        // Assert
        expect(munroDetailState.munroPictures.first.dateTime, isNull);
      });

      test('should handle repository returning empty list', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        expect(munroDetailState.galleryStatus, MunroDetailStatus.loaded);
        expect(munroDetailState.munroPictures, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle different munro IDs', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 999);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 999,
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).called(1);
      });

      test('should handle different privacy settings', () {
        // Arrange
        final mixedPrivacyPictures = [
          MunroPicture(
            uid: 'pic1',
            munroId: 1,
            authorId: 'user1',
            imageUrl: 'https://example.com/pic1.jpg',
            dateTime: DateTime(2024, 1, 1),
            postId: 'post1',
            privacy: Privacy.public,
          ),
          MunroPicture(
            uid: 'pic2',
            munroId: 1,
            authorId: 'user2',
            imageUrl: 'https://example.com/pic2.jpg',
            dateTime: DateTime(2024, 1, 2),
            postId: 'post2',
            privacy: Privacy.friends,
          ),
          MunroPicture(
            uid: 'pic3',
            munroId: 1,
            authorId: 'user3',
            imageUrl: 'https://example.com/pic3.jpg',
            dateTime: DateTime(2024, 1, 3),
            postId: 'post3',
            privacy: Privacy.private,
          ),
        ];

        // Act
        munroDetailState.setMunroPictures = mixedPrivacyPictures;

        // Assert
        expect(munroDetailState.munroPictures[0].privacy, Privacy.public);
        expect(munroDetailState.munroPictures[1].privacy, Privacy.friends);
        expect(munroDetailState.munroPictures[2].privacy, Privacy.private);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading munro pictures', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        // Act
        await munroDetailState.loadMunroPictures(munroId: 1);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating munro pictures', () async {
        // Arrange
        munroDetailState.setMunroPictures = sampleMunroPictures;
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        // Act
        await munroDetailState.paginateMunroPictures(munroId: 1);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting munro pictures', () {
        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        munroDetailState.setMunroPictures = sampleMunroPictures;

        expect(notified, true);
      });

      test('should notify listeners when adding munro pictures', () {
        munroDetailState.setMunroPictures = [sampleMunroPictures.first];

        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        munroDetailState.addMunroPictures = [sampleMunroPictures[1]];

        expect(notified, true);
      });

      test('should notify listeners when gallery status changes', () {
        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        munroDetailState.setGalleryStatus = MunroDetailStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        munroDetailState.setError = Error(message: 'test error');

        expect(notified, true);
      });
    });
  });
}
