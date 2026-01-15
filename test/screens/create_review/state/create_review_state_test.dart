import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'create_review_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ReviewsRepository,
  UserState,
  MunroState,
  Analytics,
  Logger,
])
void main() {
  late MockReviewsRepository mockReviewsRepository;
  late MockUserState mockUserState;
  late MockMunroState mockMunroState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late CreateReviewState createReviewState;

  late AppUser sampleUser;
  late List<Munro> sampleMunros;
  late Review sampleReview;

  setUp(() {
    // Sample user data for testing
    sampleUser = AppUser(
      uid: 'testUser123',
      displayName: 'Test User',
      profilePictureURL: 'https://example.com/profile.jpg',
    );

    // Sample munro data for testing
    sampleMunros = [
      Munro(
        id: 1,
        name: 'Ben Nevis',
        extra: null,
        area: 'Lochaber',
        meters: 1345,
        section: '01A',
        region: 'Western Highlands',
        feet: 4413,
        lat: 56.7969,
        lng: -5.0036,
        link: 'https://example.com/ben-nevis',
        description: 'The highest mountain in the British Isles',
        pictureURL: 'https://example.com/ben-nevis.jpg',
        startingPointURL: 'https://example.com/ben-nevis-start',
        saved: false,
      ),
      Munro(
        id: 2,
        name: 'Ben Macdui',
        extra: null,
        area: 'Cairngorms',
        meters: 1309,
        section: '09A',
        region: 'Cairngorms',
        feet: 4295,
        lat: 57.0704,
        lng: -3.6686,
        link: 'https://example.com/ben-macdui',
        description: 'The second highest mountain in the British Isles',
        pictureURL: 'https://example.com/ben-macdui.jpg',
        startingPointURL: 'https://example.com/ben-macdui-start',
        saved: false,
      ),
    ];

    // Sample review data for testing
    sampleReview = Review(
      uid: 'review123',
      munroId: 1,
      authorId: 'testUser123',
      authorDisplayName: 'Test User',
      authorProfilePictureURL: 'https://example.com/profile.jpg',
      dateTime: DateTime(2024, 1, 1),
      rating: 4,
      text: 'Great climb with fantastic views!',
    );

    mockReviewsRepository = MockReviewsRepository();
    mockUserState = MockUserState();
    mockMunroState = MockMunroState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();
    createReviewState = CreateReviewState(
      mockReviewsRepository,
      mockUserState,
      mockMunroState,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(sampleUser);

    // Reset the state to ensure clean slate for each test
    createReviewState.reset();
  });

  group('CreateReviewState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(createReviewState.status, CreateReviewStatus.initial);
        expect(createReviewState.error, isA<Error>());
        expect(createReviewState.munrosToReview, isEmpty);
        expect(createReviewState.reviews, isEmpty);
        expect(createReviewState.currentIndex, 0);
        expect(createReviewState.currentMunroRating, 0);
        expect(createReviewState.currentMunroReview, '');
        expect(createReviewState.editingReview, isNull);
      });
    });

    group('createReview', () {
      test('should create reviews successfully', () async {
        // Arrange
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Excellent mountain!');
        createReviewState.setMunroRating(2, 4);
        createReviewState.setMunroReview(2, 'Beautiful scenery');

        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.createReview();

        // Assert
        expect(createReviewState.status, CreateReviewStatus.loaded);
        verify(mockReviewsRepository.create(review: anyNamed('review'))).called(2);
        verify(mockMunroState.loadMunros()).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should create review with correct data', () async {
        // Arrange
        createReviewState.setMunrosToReview = [sampleMunros.first];
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Amazing experience!');

        Review? capturedReview;
        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((invocation) async {
          capturedReview = invocation.namedArguments[#review] as Review;
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.createReview();

        // Assert
        expect(capturedReview, isNotNull);
        expect(capturedReview!.authorId, 'testUser123');
        expect(capturedReview!.authorDisplayName, 'Test User');
        expect(capturedReview!.authorProfilePictureURL, 'https://example.com/profile.jpg');
        expect(capturedReview!.munroId, 1);
        expect(capturedReview!.rating, 5);
        expect(capturedReview!.text, 'Amazing experience!');
      });

      test('should handle error during review creation', () async {
        // Arrange
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        when(mockReviewsRepository.create(review: anyNamed('review'))).thenThrow(Exception('Network error'));

        // Act
        await createReviewState.createReview();

        // Assert
        expect(createReviewState.status, CreateReviewStatus.error);
        expect(createReviewState.error.message, 'There was an issue posting your review. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        createReviewState.setMunrosToReview = [sampleMunros.first];
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        final future = createReviewState.createReview();

        // Assert intermediate state
        expect(createReviewState.status, CreateReviewStatus.loading);

        // Wait for completion
        await future;
        expect(createReviewState.status, CreateReviewStatus.loaded);
      });

      test('should handle null user data gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        createReviewState.setMunrosToReview = [sampleMunros.first];
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        Review? capturedReview;
        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((invocation) async {
          capturedReview = invocation.namedArguments[#review] as Review;
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.createReview();

        // Assert
        expect(capturedReview, isNotNull);
        expect(capturedReview!.authorId, '');
        expect(capturedReview!.authorDisplayName, '');
        expect(capturedReview!.authorProfilePictureURL, isNull);
      });
    });

    group('editReview', () {
      test('should edit review successfully', () async {
        // Arrange
        createReviewState.loadReview = sampleReview;
        createReviewState.setCurrentMunroRating = 5;
        createReviewState.setCurrentMunroReview = 'Updated review text';

        Review? updatedReview;
        when(mockReviewsRepository.update(review: anyNamed('review'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.editReview(
          onReviewUpdated: (newReview) {
            updatedReview = newReview;
          },
        );

        // Assert
        expect(createReviewState.status, CreateReviewStatus.loaded);
        expect(updatedReview, isNotNull);
        expect(updatedReview!.rating, 5);
        expect(updatedReview!.text, 'Updated review text');
        verify(mockReviewsRepository.update(review: anyNamed('review'))).called(1);
        verify(mockMunroState.loadMunros()).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should preserve unchanged fields when editing', () async {
        // Arrange
        createReviewState.loadReview = sampleReview;
        createReviewState.setCurrentMunroRating = 3;
        createReviewState.setCurrentMunroReview = 'Different text';

        Review? updatedReview;
        when(mockReviewsRepository.update(review: anyNamed('review'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.editReview(
          onReviewUpdated: (newReview) {
            updatedReview = newReview;
          },
        );

        // Assert
        expect(updatedReview!.uid, sampleReview.uid);
        expect(updatedReview!.munroId, sampleReview.munroId);
        expect(updatedReview!.authorId, sampleReview.authorId);
        expect(updatedReview!.authorDisplayName, sampleReview.authorDisplayName);
        expect(updatedReview!.dateTime, sampleReview.dateTime);
        // Only rating and text should change
        expect(updatedReview!.rating, 3);
        expect(updatedReview!.text, 'Different text');
      });

      test('should handle error during review editing', () async {
        // Arrange
        createReviewState.loadReview = sampleReview;
        createReviewState.setCurrentMunroRating = 5;
        createReviewState.setCurrentMunroReview = 'Updated text';

        when(mockReviewsRepository.update(review: anyNamed('review'))).thenThrow(Exception('Database error'));

        // Act
        await createReviewState.editReview(
          onReviewUpdated: (newReview) {},
        );

        // Assert
        expect(createReviewState.status, CreateReviewStatus.error);
        expect(createReviewState.error.message, 'There was an issue editing your review. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        createReviewState.loadReview = sampleReview;
        createReviewState.setCurrentMunroRating = 5;
        createReviewState.setCurrentMunroReview = 'Updated text';

        when(mockReviewsRepository.update(review: anyNamed('review'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        final future = createReviewState.editReview(
          onReviewUpdated: (newReview) {},
        );

        // Assert intermediate state
        expect(createReviewState.status, CreateReviewStatus.loading);

        // Wait for completion
        await future;
        expect(createReviewState.status, CreateReviewStatus.loaded);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        createReviewState.setStatus = CreateReviewStatus.loading;
        expect(createReviewState.status, CreateReviewStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        createReviewState.setError = error;

        expect(createReviewState.status, CreateReviewStatus.error);
        expect(createReviewState.error, error);
      });

      test('setMunrosToReview should update munros and initialize reviews map', () {
        createReviewState.setMunrosToReview = sampleMunros;

        expect(createReviewState.munrosToReview, sampleMunros);
        expect(createReviewState.munrosToReview.length, 2);
        expect(createReviewState.reviews.length, 2);
        expect(createReviewState.reviews[1], {'rating': 0, 'review': ''});
        expect(createReviewState.reviews[2], {'rating': 0, 'review': ''});
      });

      test('setCurrentIndex should update current index', () {
        createReviewState.setCurrentIndex = 3;
        expect(createReviewState.currentIndex, 3);
      });

      test('setCurrentMunroRating should update current munro rating', () {
        createReviewState.setCurrentMunroRating = 4;
        expect(createReviewState.currentMunroRating, 4);
      });

      test('setCurrentMunroReview should update current munro review', () {
        createReviewState.setCurrentMunroReview = 'Test review text';
        expect(createReviewState.currentMunroReview, 'Test review text');
      });

      test('setMunroRating should update rating for existing munro', () {
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroRating(1, 5);

        expect(createReviewState.reviews[1]!['rating'], 5);
        expect(createReviewState.reviews[1]!['review'], '');
      });

      test('setMunroRating should create entry for new munro', () {
        createReviewState.setMunroRating(99, 3);

        expect(createReviewState.reviews[99], isNotNull);
        expect(createReviewState.reviews[99]!['rating'], 3);
        expect(createReviewState.reviews[99]!['review'], '');
      });

      test('setMunroReview should update review for existing munro', () {
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroReview(1, 'Great mountain!');

        expect(createReviewState.reviews[1]!['review'], 'Great mountain!');
        expect(createReviewState.reviews[1]!['rating'], 0);
      });

      test('setMunroReview should create entry for new munro', () {
        createReviewState.setMunroReview(99, 'New review');

        expect(createReviewState.reviews[99], isNotNull);
        expect(createReviewState.reviews[99]!['review'], 'New review');
        expect(createReviewState.reviews[99]!['rating'], 0);
      });

      test('loadReview should load review data', () {
        createReviewState.loadReview = sampleReview;

        expect(createReviewState.editingReview, sampleReview);
        expect(createReviewState.currentMunroRating, sampleReview.rating);
        expect(createReviewState.currentMunroReview, sampleReview.text);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        createReviewState.setMunrosToReview = sampleMunros;
        final reviewsBeforeReset = createReviewState.reviews;
        createReviewState.setCurrentIndex = 1;
        createReviewState.setCurrentMunroRating = 5;
        createReviewState.setCurrentMunroReview = 'Test review';
        createReviewState.loadReview = sampleReview;
        createReviewState.setStatus = CreateReviewStatus.loaded;

        // Act
        createReviewState.reset();

        // Assert
        expect(createReviewState.status, CreateReviewStatus.initial);
        expect(createReviewState.error, isA<Error>());
        expect(createReviewState.munrosToReview, isEmpty);
        // Note: reset() does not clear the reviews map, only munrosToReview
        expect(createReviewState.reviews, reviewsBeforeReset);
        expect(createReviewState.currentIndex, 0);
        expect(createReviewState.currentMunroRating, 0);
        expect(createReviewState.currentMunroReview, '');
        expect(createReviewState.editingReview, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty munros list', () {
        createReviewState.setMunrosToReview = [];

        expect(createReviewState.munrosToReview, isEmpty);
        expect(createReviewState.reviews, isEmpty);
      });

      test('should handle creating review with empty reviews map', () async {
        // Arrange
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.createReview();

        // Assert
        expect(createReviewState.status, CreateReviewStatus.loaded);
        verifyNever(mockReviewsRepository.create(review: anyNamed('review')));
      });

      test('should handle multiple munros with different ratings', () {
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroRating(2, 3);
        createReviewState.setMunroReview(1, 'Excellent');
        createReviewState.setMunroReview(2, 'Good');

        expect(createReviewState.reviews[1]!['rating'], 5);
        expect(createReviewState.reviews[1]!['review'], 'Excellent');
        expect(createReviewState.reviews[2]!['rating'], 3);
        expect(createReviewState.reviews[2]!['review'], 'Good');
      });

      test('should handle zero rating', () {
        createReviewState.setMunroRating(1, 0);
        expect(createReviewState.reviews[1]!['rating'], 0);
      });

      test('should handle empty review text', () {
        createReviewState.setMunroReview(1, '');
        expect(createReviewState.reviews[1]!['review'], '');
      });

      test('should handle very long review text', () {
        final longText = 'A' * 10000;
        createReviewState.setMunroReview(1, longText);
        expect(createReviewState.reviews[1]!['review'], longText);
      });

      test('should handle null profile picture URL in user', () async {
        // Arrange
        final userWithoutPicture = AppUser(
          uid: 'testUser123',
          displayName: 'Test User',
          profilePictureURL: null,
        );
        when(mockUserState.currentUser).thenReturn(userWithoutPicture);

        createReviewState.setMunrosToReview = [sampleMunros.first];
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        Review? capturedReview;
        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((invocation) async {
          capturedReview = invocation.namedArguments[#review] as Review;
        });
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await createReviewState.createReview();

        // Assert
        expect(capturedReview!.authorProfilePictureURL, isNull);
      });

      test('should overwrite existing review data when setMunrosToReview is called', () {
        // Arrange
        createReviewState.setMunrosToReview = sampleMunros;
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        // Act - set new munros
        final newMunros = [sampleMunros.first];
        createReviewState.setMunrosToReview = newMunros;

        // Assert - reviews should be reset
        expect(createReviewState.munrosToReview.length, 1);
        expect(createReviewState.reviews.length, 1);
        expect(createReviewState.reviews[1]!['rating'], 0);
        expect(createReviewState.reviews[1]!['review'], '');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when creating reviews', () async {
        // Arrange
        createReviewState.setMunrosToReview = [sampleMunros.first];
        createReviewState.setMunroRating(1, 5);
        createReviewState.setMunroReview(1, 'Test review');

        when(mockReviewsRepository.create(review: anyNamed('review'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        bool notified = false;
        createReviewState.addListener(() => notified = true);

        // Act
        await createReviewState.createReview();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when editing review', () async {
        // Arrange
        createReviewState.loadReview = sampleReview;
        createReviewState.setCurrentMunroRating = 5;
        createReviewState.setCurrentMunroReview = 'Updated text';

        when(mockReviewsRepository.update(review: anyNamed('review'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        bool notified = false;
        createReviewState.addListener(() => notified = true);

        // Act
        await createReviewState.editReview(onReviewUpdated: (newReview) {});

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setStatus = CreateReviewStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when setting munros to review', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setMunrosToReview = sampleMunros;

        expect(notified, true);
      });

      test('should notify listeners when setting current index', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setCurrentIndex = 2;

        expect(notified, true);
      });

      test('should notify listeners when setting current munro rating', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setCurrentMunroRating = 4;

        expect(notified, true);
      });

      test('should notify listeners when setting munro rating', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setMunroRating(1, 5);

        expect(notified, true);
      });

      test('should notify listeners when setting munro review', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setMunroReview(1, 'Test review');

        expect(notified, true);
      });

      test('should notify listeners when setting current munro review', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.setCurrentMunroReview = 'Test text';

        expect(notified, true);
      });

      test('should notify listeners when loading review', () {
        bool notified = false;
        createReviewState.addListener(() => notified = true);

        createReviewState.loadReview = sampleReview;

        expect(notified, true);
      });

      test('should not notify listeners when resetting', () {
        createReviewState.setMunrosToReview = sampleMunros;

        bool notified = false;
        // The reset method does not call notifyListeners
        createReviewState.addListener(() => notified = true);

        createReviewState.reset();

        // reset() does not notify listeners based on the implementation
        expect(notified, false);
        // But state should be reset
        expect(createReviewState.status, CreateReviewStatus.initial);
        expect(createReviewState.munrosToReview, isEmpty);
      });
    });
  });
}
