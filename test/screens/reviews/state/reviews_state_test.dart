import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'reviews_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ReviewsRepository,
  MunroState,
  UserState,
  Analytics,
  Logger,
])
void main() {
  late MockReviewsRepository mockReviewsRepository;
  late MockMunroState mockMunroState;
  late MockUserState mockUserState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late ReviewsState reviewsState;

  late List<Review> sampleReviews;
  late Munro sampleMunro;

  setUp(() {
    // Sample munro for testing
    sampleMunro = Munro(
      id: 1,
      name: 'Ben Nevis',
      extra: 'Mountain',
      area: 'Lochaber',
      meters: 1345,
      section: 'Section 1',
      region: 'Grampian Mountains',
      feet: 4411,
      lat: 56.79685,
      lng: -5.00354,
      link: 'https://example.com/ben-nevis',
      description: 'The highest mountain in the British Isles',
      pictureURL: 'https://example.com/ben-nevis.jpg',
      startingPointURL: 'https://example.com/ben-nevis-start',
      saved: false,
      averageRating: 4.5,
      reviewCount: 10,
      commonlyClimbedWith: [],
    );

    // Sample review data for testing
    sampleReviews = [
      Review(
        uid: 'review1',
        munroId: 1,
        authorId: 'user1',
        authorDisplayName: 'John Doe',
        authorProfilePictureURL: 'https://example.com/user1.jpg',
        dateTime: DateTime(2023, 1, 15),
        rating: 5,
        text: 'Amazing climb with stunning views!',
      ),
      Review(
        uid: 'review2',
        munroId: 1,
        authorId: 'user2',
        authorDisplayName: 'Jane Smith',
        authorProfilePictureURL: 'https://example.com/user2.jpg',
        dateTime: DateTime(2023, 2, 20),
        rating: 4,
        text: 'Great experience, but weather was challenging.',
      ),
      Review(
        uid: 'review3',
        munroId: 1,
        authorId: 'user3',
        authorDisplayName: 'Bob Johnson',
        authorProfilePictureURL: null,
        dateTime: DateTime(2023, 3, 10),
        rating: 5,
        text: 'Would definitely recommend this route!',
      ),
    ];

    mockReviewsRepository = MockReviewsRepository();
    mockMunroState = MockMunroState();
    mockUserState = MockUserState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();
    reviewsState = ReviewsState(
      mockReviewsRepository,
      mockMunroState,
      mockUserState,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);

    // Default mock behavior for MunroState
    when(mockMunroState.selectedMunroId).thenReturn(sampleMunro.id);
  });

  group('ReviewsState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(reviewsState.status, ReviewsStatus.initial);
        expect(reviewsState.error, isA<Error>());
        expect(reviewsState.reviews, isEmpty);
      });
    });

    group('getMunroReviews', () {
      test('should load reviews successfully', () async {
        // Arrange
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleReviews);

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.status, ReviewsStatus.loaded);
        expect(reviewsState.reviews, sampleReviews);
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading reviews', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleReviews);

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle error during loading reviews', () async {
        // Arrange
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Network error'));

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.status, ReviewsStatus.error);
        expect(reviewsState.error.message, 'There was an issue getting reviews for this munro. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleReviews;
        });

        // Act
        final future = reviewsState.getMunroReviews(sampleMunro.id);

        // Assert intermediate state
        expect(reviewsState.status, ReviewsStatus.loading);

        // Wait for completion
        await future;
        expect(reviewsState.status, ReviewsStatus.loaded);
      });
    });

    group('paginateMunroReviews', () {
      test('should paginate reviews successfully', () async {
        // Set initial reviews - use a copy to avoid mutating sampleReviews
        reviewsState.setReviews = List.from(sampleReviews);
        // Arrange
        final additionalReviews = [
          Review(
            uid: 'review4',
            munroId: 1,
            authorId: 'user4',
            authorDisplayName: 'Alice Williams',
            authorProfilePictureURL: 'https://example.com/user4.jpg',
            dateTime: DateTime(2023, 4, 5),
            rating: 4,
            text: 'Loved the challenging terrain!',
          ),
        ];

        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalReviews);

        // Act
        await reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.status, ReviewsStatus.loaded);
        expect(reviewsState.reviews.length, 4);
        expect(reviewsState.reviews.last.authorDisplayName, 'Alice Williams');
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial review count
        final initialCount = reviewsState.reviews.length;

        // Act
        await reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.status, ReviewsStatus.error);
        expect(reviewsState.error.message, 'There was an issue getting reviews for this munro. Please try again');
        // Original reviews should remain unchanged
        expect(reviewsState.reviews.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert intermediate state
        expect(reviewsState.status, ReviewsStatus.paginating);

        // Wait for completion
        await future;
        expect(reviewsState.status, ReviewsStatus.loaded);
      });
    });

    group('deleteReview', () {
      test('should delete review successfully', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final reviewToDelete = sampleReviews[1];
        when(mockReviewsRepository.delete(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        // Act
        await reviewsState.deleteReview(review: reviewToDelete);

        // Assert
        expect(reviewsState.reviews.length, 2);
        expect(reviewsState.reviews.any((r) => r.uid == 'review2'), false);
        verify(mockReviewsRepository.delete(uid: 'review2')).called(1);
        verify(mockMunroState.loadMunros()).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during delete', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final reviewToDelete = sampleReviews[0];
        when(mockReviewsRepository.delete(uid: anyNamed('uid'))).thenThrow(Exception('Delete error'));

        // Store initial review count
        final initialCount = reviewsState.reviews.length;

        // Act
        await reviewsState.deleteReview(review: reviewToDelete);

        // Assert
        expect(reviewsState.status, ReviewsStatus.error);
        expect(reviewsState.error.message, 'There was an issue deleting your review. Please try again');
        // Reviews should remain unchanged on error
        expect(reviewsState.reviews.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should not call loadMunros if delete fails', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final reviewToDelete = sampleReviews[0];
        when(mockReviewsRepository.delete(uid: anyNamed('uid'))).thenThrow(Exception('Delete error'));

        // Act
        await reviewsState.deleteReview(review: reviewToDelete);

        // Assert
        verifyNever(mockMunroState.loadMunros());
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        reviewsState.setStatus = ReviewsStatus.loading;
        expect(reviewsState.status, ReviewsStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        reviewsState.setError = error;

        expect(reviewsState.status, ReviewsStatus.error);
        expect(reviewsState.error, error);
      });

      test('setReviews should update reviews list', () {
        reviewsState.setReviews = sampleReviews;

        expect(reviewsState.reviews, sampleReviews);
        expect(reviewsState.reviews.length, 3);
      });

      test('addReviews should append to existing reviews', () {
        reviewsState.setReviews = [sampleReviews.first];

        reviewsState.addReviews = [sampleReviews[1], sampleReviews[2]];

        expect(reviewsState.reviews.length, 3);
        expect(reviewsState.reviews[0], sampleReviews[0]);
        expect(reviewsState.reviews[1], sampleReviews[1]);
        expect(reviewsState.reviews[2], sampleReviews[2]);
      });

      test('replaceReview should update existing review', () {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final updatedReview = sampleReviews[1].copyWith(
          rating: 5,
          text: 'Updated review text',
        );

        // Act
        reviewsState.replaceReview = updatedReview;

        // Assert
        expect(reviewsState.reviews.length, 3);
        expect(reviewsState.reviews[1].rating, 5);
        expect(reviewsState.reviews[1].text, 'Updated review text');
      });

      test('replaceReview should not change list if review not found', () {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final nonExistentReview = Review(
          uid: 'nonexistent',
          munroId: 1,
          authorId: 'user99',
          authorDisplayName: 'Nobody',
          authorProfilePictureURL: null,
          dateTime: DateTime.now(),
          rating: 3,
          text: 'This review does not exist',
        );

        // Act
        reviewsState.replaceReview = nonExistentReview;

        // Assert
        expect(reviewsState.reviews.length, 3);
        expect(reviewsState.reviews, sampleReviews);
      });

      test('removeReview should remove review from list', () {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final reviewToRemove = sampleReviews[1];

        // Act
        reviewsState.removeReview(reviewToRemove);

        // Assert
        expect(reviewsState.reviews.length, 2);
        expect(reviewsState.reviews.any((r) => r.uid == 'review2'), false);
      });
    });

    group('Edge Cases', () {
      test('should handle empty reviews list on pagination', () async {
        // Arrange - start with empty list
        expect(reviewsState.reviews, isEmpty);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleReviews);

        // Act
        await reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.reviews, sampleReviews);
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final reviewWithNullURL = Review(
          uid: 'review5',
          munroId: 1,
          authorId: 'user5',
          authorDisplayName: 'User Five',
          authorProfilePictureURL: null,
          dateTime: DateTime(2023, 5, 1),
          rating: 3,
          text: 'Good climb',
        );

        // Act
        reviewsState.setReviews = [reviewWithNullURL];

        // Assert
        expect(reviewsState.reviews.first.authorProfilePictureURL, isNull);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        expect(reviewsState.status, ReviewsStatus.loaded);
        expect(reviewsState.reviews, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        verify(mockReviewsRepository.readReviewsFromMunro(
          munroId: 1,
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle removing review that does not exist', () {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final nonExistentReview = Review(
          uid: 'nonexistent',
          munroId: 1,
          authorId: 'user99',
          authorDisplayName: 'Nobody',
          authorProfilePictureURL: null,
          dateTime: DateTime.now(),
          rating: 3,
          text: 'This review does not exist',
        );

        // Act
        reviewsState.removeReview(nonExistentReview);

        // Assert
        expect(reviewsState.reviews.length, 3);
        expect(reviewsState.reviews, sampleReviews);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading reviews', () async {
        // Arrange
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleReviews);

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        // Act
        await reviewsState.getMunroReviews(sampleMunro.id);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating reviews', () async {
        // Arrange
        reviewsState.setReviews = sampleReviews;
        when(mockReviewsRepository.readReviewsFromMunro(
          munroId: anyNamed('munroId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        // Act
        await reviewsState.paginateMunroReviews(sampleMunro.id);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when deleting review', () async {
        // Arrange
        reviewsState.setReviews = List.from(sampleReviews);
        final reviewToDelete = sampleReviews[0];
        when(mockReviewsRepository.delete(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        when(mockMunroState.loadMunros()).thenAnswer((_) async => {});

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        // Act
        await reviewsState.deleteReview(review: reviewToDelete);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting reviews', () {
        bool notified = false;
        reviewsState.addListener(() => notified = true);

        reviewsState.setReviews = sampleReviews;

        expect(notified, true);
      });

      test('should notify listeners when adding reviews', () {
        reviewsState.setReviews = [sampleReviews.first];

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        reviewsState.addReviews = [sampleReviews[1]];

        expect(notified, true);
      });

      test('should notify listeners when replacing review', () {
        reviewsState.setReviews = List.from(sampleReviews);

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        final updatedReview = sampleReviews[0].copyWith(rating: 4);
        reviewsState.replaceReview = updatedReview;

        expect(notified, true);
      });

      test('should notify listeners when removing review', () {
        reviewsState.setReviews = List.from(sampleReviews);

        bool notified = false;
        reviewsState.addListener(() => notified = true);

        reviewsState.removeReview(sampleReviews[0]);

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        reviewsState.addListener(() => notified = true);

        reviewsState.setStatus = ReviewsStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        reviewsState.addListener(() => notified = true);

        reviewsState.setError = Error(message: 'test error');

        expect(notified, true);
      });
    });
  });
}
