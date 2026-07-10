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
  ReviewsRepository,
  UserState,
  Logger,
])
void main() {
  late MockMunroPicturesRepository mockMunroPicturesRepository;
  late MockReviewsRepository mockReviewsRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late MunroDetailState munroDetailState;

  late Munro sampleMunro;
  late List<MunroPicture> sampleMunroPictures;

  setUp(() {
    sampleMunro = Munro(
      id: 1,
      name: 'Ben Nevis',
      extra: null,
      area: 'Fort William',
      meters: 1345,
      section: '1',
      region: 'Lochaber',
      feet: 4411,
      lat: 56.79685,
      lng: -5.00360,
      link: '',
      description: '',
      pictureURL: '',
      startingPointURL: '',
      commonlyClimbedWith: [],
      totalSummitCount: 0,
    );

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
    mockReviewsRepository = MockReviewsRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    munroDetailState = MunroDetailState(
      mockMunroPicturesRepository,
      mockReviewsRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);

    // Default mock behavior for ReviewsRepository so picture-focused tests
    // don't need to stub it individually.
    when(mockReviewsRepository.readReviewsFromMunro(
      munroId: anyNamed('munroId'),
      excludedAuthorIds: anyNamed('excludedAuthorIds'),
      offset: anyNamed('offset'),
    )).thenAnswer((_) async => []);
  });

  group('MunroDetailState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(munroDetailState.status, MunroDetailStatus.initial);
        expect(munroDetailState.error, isA<Error>());
        expect(munroDetailState.munroPictures, isEmpty);
      });
    });

    group('init', () {
      test('should load munro pictures successfully', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await munroDetailState.init(sampleMunro);
        // Wait for the underlying Future.wait chain to complete.
        await Future.delayed(Duration.zero);

        // Assert
        expect(munroDetailState.status, MunroDetailStatus.loaded);
        expect(munroDetailState.selectedMunro, sampleMunro);
        expect(munroDetailState.munroPictures, sampleMunroPictures);
        expect(munroDetailState.munroPictures.length, 3);
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
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
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 4,
        )).called(1);
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => throw Exception('Network error'));

        // Act
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        expect(munroDetailState.status, MunroDetailStatus.error);
        expect(munroDetailState.error.message, 'There was an issue loading data for this munro. Please try again.');
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
        final future = munroDetailState.init(sampleMunro);

        // Assert intermediate state
        expect(munroDetailState.status, MunroDetailStatus.loading);

        // Wait for completion
        await future;
        await Future.delayed(Duration(milliseconds: 150));
        expect(munroDetailState.status, MunroDetailStatus.loaded);
      });
    });

    group('Edge Cases', () {
      test('should handle null dateTime in pictures', () async {
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
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => [pictureWithNullDateTime]);

        // Act
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

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
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        expect(munroDetailState.status, MunroDetailStatus.loaded);
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
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 4,
        )).called(1);
      });

      test('should handle different munro IDs', () async {
        // Arrange
        final otherMunro = sampleMunro.copy(id: 999);
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => []);

        // Act
        await munroDetailState.init(otherMunro);
        await Future.delayed(Duration.zero);

        // Assert
        verify(mockMunroPicturesRepository.readMunroPictures(
          munroId: 999,
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).called(1);
      });

      test('should handle different privacy settings', () async {
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
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => mixedPrivacyPictures);

        // Act
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

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
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when error occurs during loading', () async {
        // Arrange
        when(mockMunroPicturesRepository.readMunroPictures(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
          count: anyNamed('count'),
        )).thenAnswer((_) async => throw Exception('Network error'));

        bool notified = false;
        munroDetailState.addListener(() => notified = true);

        // Act
        await munroDetailState.init(sampleMunro);
        await Future.delayed(Duration.zero);

        // Assert
        expect(notified, true);
      });
    });
  });
}
