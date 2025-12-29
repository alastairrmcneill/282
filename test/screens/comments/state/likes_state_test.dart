import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'likes_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  LikesRepository,
  UserState,
  Logger,
])
void main() {
  late MockLikesRepository mockLikesRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late LikesState likesState;

  late List<Like> sampleLikes;

  setUp(() {
    // Sample like data for testing
    sampleLikes = [
      Like(
        uid: 'like1',
        postId: 'post1',
        userId: 'user1',
        userDisplayName: 'User One',
        userProfilePictureURL: 'https://example.com/user1.jpg',
        dateTimeCreated: DateTime(2024, 1, 1, 10, 0),
      ),
      Like(
        uid: 'like2',
        postId: 'post1',
        userId: 'user2',
        userDisplayName: 'User Two',
        userProfilePictureURL: 'https://example.com/user2.jpg',
        dateTimeCreated: DateTime(2024, 1, 1, 9, 0),
      ),
      Like(
        uid: 'like3',
        postId: 'post1',
        userId: 'user3',
        userDisplayName: 'User Three',
        userProfilePictureURL: null,
        dateTimeCreated: DateTime(2024, 1, 1, 8, 0),
      ),
    ];

    mockLikesRepository = MockLikesRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    likesState = LikesState(
      mockLikesRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    likesState.reset();
  });

  group('LikesState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(likesState.status, LikesStatus.initial);
        expect(likesState.error, isA<Error>());
        expect(likesState.likes, isEmpty);
      });
    });

    group('getPostLikes', () {
      test('should load post likes successfully', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(likesState.status, LikesStatus.loaded);
        expect(likesState.likes, sampleLikes);
        expect(likesState.postId, 'post1');
        verify(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: [],
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        verify(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: blockedUsers,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during loading likes', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenThrow(Exception('Network error'));

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(likesState.status, LikesStatus.error);
        expect(likesState.error.message, 'There was an error loading likes.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleLikes;
        });

        // Act
        final future = likesState.getPostLikes(postId: 'post1');

        // Assert intermediate state
        expect(likesState.status, LikesStatus.loading);

        // Wait for completion
        await future;
        expect(likesState.status, LikesStatus.loaded);
      });

      test('should update postId when loading likes', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(likesState.postId, 'post1');
      });
    });

    group('paginatePostLikes', () {
      test('should paginate post likes successfully', () async {
        // Arrange - Set initial likes first
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        final additionalLikes = [
          Like(
            uid: 'like4',
            postId: 'post1',
            userId: 'user4',
            userDisplayName: 'User Four',
            userProfilePictureURL: 'https://example.com/user4.jpg',
            dateTimeCreated: DateTime(2024, 1, 1, 7, 0),
          ),
        ];

        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalLikes);

        // Act
        await likesState.paginatePostLikes();

        // Assert
        expect(likesState.status, LikesStatus.loaded);
        expect(likesState.likes.length, 4);
        expect(likesState.likes.last.userDisplayName, 'User Four');
        verify(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await likesState.paginatePostLikes();

        // Assert
        verify(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial like count
        final initialCount = likesState.likes.length;

        // Act
        await likesState.paginatePostLikes();

        // Assert
        expect(likesState.status, LikesStatus.error);
        expect(likesState.error.message, 'There was an error loading more likes.');
        // Original likes should remain unchanged
        expect(likesState.likes.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = likesState.paginatePostLikes();

        // Assert intermediate state
        expect(likesState.status, LikesStatus.paginating);

        // Wait for completion
        await future;
        expect(likesState.status, LikesStatus.loaded);
      });
    });

    group('Setters', () {
      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        likesState.setError = error;

        expect(likesState.status, LikesStatus.error);
        expect(likesState.error, error);
      });

      test('setPostId should update postId', () {
        likesState.setPostId = 'post2';

        expect(likesState.postId, 'post2');
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        // Act
        likesState.reset();

        // Assert
        expect(likesState.status, LikesStatus.initial);
        expect(likesState.error, isA<Error>());
        expect(likesState.likes, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty likes list on pagination', () async {
        // Arrange - start with empty list by calling getPostLikes first
        when(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: [],
          offset: 0,
        )).thenAnswer((_) async => []);
        await likesState.getPostLikes(postId: 'post1');

        expect(likesState.likes, isEmpty);

        // Now set up mock for pagination with offset
        when(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: [],
          offset: 0,
        )).thenAnswer((_) async => sampleLikes);

        // Act
        await likesState.paginatePostLikes();

        // Assert
        expect(likesState.likes, sampleLikes);
      });

      test('should handle null profile picture URLs', () async {
        // Arrange
        final likeWithNullURL = Like(
          uid: 'like5',
          postId: 'post1',
          userId: 'user5',
          userDisplayName: 'User Five',
          userProfilePictureURL: null,
          dateTimeCreated: DateTime(2024, 1, 1, 6, 0),
        );

        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => [likeWithNullURL]);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(likesState.likes.first.userProfilePictureURL, isNull);
      });

      test('should handle repository returning empty list', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(likesState.status, LikesStatus.loaded);
        expect(likesState.likes, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        verify(mockLikesRepository.readPostLikes(
          postId: 'post1',
          excludedUserIds: blockedUsers,
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading likes', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);

        bool notified = false;
        likesState.addListener(() => notified = true);

        // Act
        await likesState.getPostLikes(postId: 'post1');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating likes', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        likesState.addListener(() => notified = true);

        // Act
        await likesState.paginatePostLikes();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting postId', () {
        bool notified = false;
        likesState.addListener(() => notified = true);

        likesState.setPostId = 'post2';

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        likesState.addListener(() => notified = true);

        likesState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when resetting', () async {
        // Arrange
        when(mockLikesRepository.readPostLikes(
          postId: anyNamed('postId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleLikes);
        await likesState.getPostLikes(postId: 'post1');

        bool notified = false;
        likesState.addListener(() => notified = true);

        // Act
        likesState.reset();

        // Assert
        expect(notified, true);
        expect(likesState.status, LikesStatus.initial);
        expect(likesState.likes, isEmpty);
      });
    });
  });
}
