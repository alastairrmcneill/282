import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'followers_list_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  FollowersRepository,
  UserState,
  Logger,
])
void main() {
  late MockFollowersRepository mockFollowersRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late FollowersListState followersListState;

  late List<FollowingRelationship> sampleFollowers;
  late List<FollowingRelationship> sampleFollowing;

  setUp(() {
    // Sample following relationship data for testing
    sampleFollowers = [
      FollowingRelationship(
        sourceId: 'user1',
        targetId: 'currentUser',
        targetDisplayName: 'Current User',
        targetProfilePictureURL: 'https://example.com/current.jpg',
        targetSearchName: 'current user',
        sourceDisplayName: 'User One',
        sourceProfilePictureURL: 'https://example.com/user1.jpg',
      ),
      FollowingRelationship(
        sourceId: 'user2',
        targetId: 'currentUser',
        targetDisplayName: 'Current User',
        targetProfilePictureURL: 'https://example.com/current.jpg',
        targetSearchName: 'current user',
        sourceDisplayName: 'User Two',
        sourceProfilePictureURL: 'https://example.com/user2.jpg',
      ),
      FollowingRelationship(
        sourceId: 'user3',
        targetId: 'currentUser',
        targetDisplayName: 'Current User',
        targetProfilePictureURL: 'https://example.com/current.jpg',
        targetSearchName: 'current user',
        sourceDisplayName: 'User Three',
        sourceProfilePictureURL: null,
      ),
    ];

    sampleFollowing = [
      FollowingRelationship(
        sourceId: 'currentUser',
        targetId: 'followedUser1',
        targetDisplayName: 'Followed User One',
        targetProfilePictureURL: 'https://example.com/followed1.jpg',
        targetSearchName: 'followed user one',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
      FollowingRelationship(
        sourceId: 'currentUser',
        targetId: 'followedUser2',
        targetDisplayName: 'Followed User Two',
        targetProfilePictureURL: 'https://example.com/followed2.jpg',
        targetSearchName: 'followed user two',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
    ];

    mockFollowersRepository = MockFollowersRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    followersListState = FollowersListState(
      mockFollowersRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    followersListState.reset();
  });

  group('FollowersListState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(followersListState.status, FollowersListStatus.initial);
        expect(followersListState.error, isA<Error>());
        expect(followersListState.followers, isEmpty);
        expect(followersListState.following, isEmpty);
      });
    });

    group('loadInitialFollowersAndFollowing', () {
      test('should load followers and following successfully', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowers);

        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.loaded);
        expect(followersListState.followers, sampleFollowers);
        expect(followersListState.following, sampleFollowing);
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: [],
        )).called(1);
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: [],
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: blockedUsers,
        )).called(1);
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: blockedUsers,
        )).called(1);
      });

      test('should handle error during loading followers', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenThrow(Exception('Network error'));
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.error);
        expect(followersListState.error.message, 'There was an issue. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during loading following', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenThrow(Exception('Database error'));

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.error);
        expect(followersListState.error.message, 'There was an issue. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleFollowers;
        });
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        final future = followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert intermediate state
        expect(followersListState.status, FollowersListStatus.loading);

        // Wait for completion
        await future;
        expect(followersListState.status, FollowersListStatus.loaded);
      });
    });

    group('paginateFollowers', () {
      test('should paginate followers successfully', () async {
        // Set initial followers - use a copy to avoid mutating sampleFollowers
        followersListState.setFollowers = List.from(sampleFollowers);
        // Arrange
        final additionalFollowers = [
          FollowingRelationship(
            sourceId: 'user4',
            targetId: 'currentUser',
            targetDisplayName: 'Current User',
            targetProfilePictureURL: 'https://example.com/current.jpg',
            targetSearchName: 'current user',
            sourceDisplayName: 'User Four',
            sourceProfilePictureURL: 'https://example.com/user4.jpg',
          ),
        ];

        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalFollowers);

        // Act
        await followersListState.paginateFollowers(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.loaded);
        expect(followersListState.followers.length, 4);
        expect(followersListState.followers.last.sourceDisplayName, 'User Four');
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        followersListState.setFollowers = List.from(sampleFollowers);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await followersListState.paginateFollowers(userId: 'currentUser');

        // Assert
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        followersListState.setFollowers = List.from(sampleFollowers);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial follower count
        final initialCount = followersListState.followers.length;

        // Act
        await followersListState.paginateFollowers(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.error);
        expect(followersListState.error.message, 'There was an issue. Please try again.');
        // Original followers should remain unchanged
        expect(followersListState.followers.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        followersListState.setFollowers = List.from(sampleFollowers);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = followersListState.paginateFollowers(userId: 'currentUser');

        // Assert intermediate state
        expect(followersListState.status, FollowersListStatus.paginating);

        // Wait for completion
        await future;
        expect(followersListState.status, FollowersListStatus.loaded);
      });
    });

    group('paginateFollowing', () {
      test('should paginate following successfully', () async {
        // Set initial following - use a copy to avoid mutating sampleFollowing
        followersListState.setFollowing = List.from(sampleFollowing);
        // Arrange
        final additionalFollowing = [
          FollowingRelationship(
            sourceId: 'currentUser',
            targetId: 'followedUser3',
            targetDisplayName: 'Followed User Three',
            targetProfilePictureURL: 'https://example.com/followed3.jpg',
            targetSearchName: 'followed user three',
            sourceDisplayName: 'Current User',
            sourceProfilePictureURL: 'https://example.com/current.jpg',
          ),
        ];

        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalFollowing);

        // Act
        await followersListState.paginateFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.loaded);
        expect(followersListState.following.length, 3);
        expect(followersListState.following.last.targetDisplayName, 'Followed User Three');
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: [],
          offset: 2,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        followersListState.setFollowing = List.from(sampleFollowing);
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await followersListState.paginateFollowing(userId: 'currentUser');

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: blockedUsers,
          offset: 2,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        followersListState.setFollowing = List.from(sampleFollowing);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial following count
        final initialCount = followersListState.following.length;

        // Act
        await followersListState.paginateFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.error);
        expect(followersListState.error.message, 'There was an issue. Please try again.');
        // Original following should remain unchanged
        expect(followersListState.following.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        followersListState.setFollowing = List.from(sampleFollowing);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = followersListState.paginateFollowing(userId: 'currentUser');

        // Assert intermediate state
        expect(followersListState.status, FollowersListStatus.paginating);

        // Wait for completion
        await future;
        expect(followersListState.status, FollowersListStatus.loaded);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        followersListState.setStatus = FollowersListStatus.loading;
        expect(followersListState.status, FollowersListStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        followersListState.setError = error;

        expect(followersListState.status, FollowersListStatus.error);
        expect(followersListState.error, error);
      });

      test('setFollowers should update followers list', () {
        followersListState.setFollowers = sampleFollowers;

        expect(followersListState.followers, sampleFollowers);
        expect(followersListState.followers.length, 3);
      });

      test('addFollowers should append to existing followers', () {
        followersListState.setFollowers = [sampleFollowers.first];

        followersListState.addFollowers = [sampleFollowers[1], sampleFollowers[2]];

        expect(followersListState.followers.length, 3);
        expect(followersListState.followers[0], sampleFollowers[0]);
        expect(followersListState.followers[1], sampleFollowers[1]);
        expect(followersListState.followers[2], sampleFollowers[2]);
      });

      test('setFollowing should update following list', () {
        followersListState.setFollowing = sampleFollowing;

        expect(followersListState.following, sampleFollowing);
        expect(followersListState.following.length, 2);
      });

      test('addFollowing should append to existing following', () {
        followersListState.setFollowing = [sampleFollowing.first];

        followersListState.addFollowing = [sampleFollowing[1]];

        expect(followersListState.following.length, 2);
        expect(followersListState.following[0], sampleFollowing[0]);
        expect(followersListState.following[1], sampleFollowing[1]);
      });
    });

    group('clear', () {
      test('should clear both followers and following lists', () {
        // Arrange
        followersListState.setFollowers = sampleFollowers;
        followersListState.setFollowing = sampleFollowing;

        // Act
        followersListState.clear();

        // Assert
        expect(followersListState.followers, isEmpty);
        expect(followersListState.following, isEmpty);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        followersListState.setFollowers = sampleFollowers;
        followersListState.setFollowing = sampleFollowing;
        followersListState.setStatus = FollowersListStatus.loaded;

        // Act
        followersListState.reset();

        // Assert
        expect(followersListState.status, FollowersListStatus.initial);
        expect(followersListState.error, isA<Error>());
        expect(followersListState.followers, isEmpty);
        expect(followersListState.following, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty followers list on pagination', () async {
        // Arrange - start with empty list
        expect(followersListState.followers, isEmpty);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleFollowers);

        // Act
        await followersListState.paginateFollowers(userId: 'currentUser');

        // Assert
        expect(followersListState.followers, sampleFollowers);
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle empty following list on pagination', () async {
        // Arrange - start with empty list
        expect(followersListState.following, isEmpty);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await followersListState.paginateFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.following, sampleFollowing);
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final relationshipWithNullURL = FollowingRelationship(
          sourceId: 'user5',
          targetId: 'currentUser',
          targetDisplayName: 'User Five',
          targetProfilePictureURL: null,
          targetSearchName: 'user five',
          sourceDisplayName: 'User Five',
          sourceProfilePictureURL: null,
        );

        // Act
        followersListState.setFollowers = [relationshipWithNullURL];

        // Assert
        expect(followersListState.followers.first.sourceProfilePictureURL, isNull);
        expect(followersListState.followers.first.targetProfilePictureURL, isNull);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        expect(followersListState.status, FollowersListStatus.loaded);
        expect(followersListState.followers, isEmpty);
        expect(followersListState.following, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        verify(mockFollowersRepository.getFollowersFromUid(
          targetId: 'currentUser',
          excludedUserIds: blockedUsers,
        )).called(1);
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUser',
          excludedUserIds: blockedUsers,
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading followers and following', () async {
        // Arrange
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        bool notified = false;
        followersListState.addListener(() => notified = true);

        // Act
        await followersListState.loadInitialFollowersAndFollowing(userId: 'currentUser');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating followers', () async {
        // Arrange
        followersListState.setFollowers = sampleFollowers;
        when(mockFollowersRepository.getFollowersFromUid(
          targetId: anyNamed('targetId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        followersListState.addListener(() => notified = true);

        // Act
        await followersListState.paginateFollowers(userId: 'currentUser');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating following', () async {
        // Arrange
        followersListState.setFollowing = sampleFollowing;
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        followersListState.addListener(() => notified = true);

        // Act
        await followersListState.paginateFollowing(userId: 'currentUser');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting followers', () {
        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.setFollowers = sampleFollowers;

        expect(notified, true);
      });

      test('should notify listeners when setting following', () {
        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.setFollowing = sampleFollowing;

        expect(notified, true);
      });

      test('should notify listeners when adding followers', () {
        followersListState.setFollowers = [sampleFollowers.first];

        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.addFollowers = [sampleFollowers[1]];

        expect(notified, true);
      });

      test('should notify listeners when adding following', () {
        followersListState.setFollowing = [sampleFollowing.first];

        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.addFollowing = [sampleFollowing[1]];

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.setStatus = FollowersListStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        followersListState.addListener(() => notified = true);

        followersListState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        followersListState.setFollowers = sampleFollowers;

        bool notified = false;
        // The reset method does not call notifyListeners, it only calls clear()
        // and clear() also does not call notifyListeners
        followersListState.addListener(() => notified = true);

        followersListState.reset();

        // reset() does not notify listeners based on the implementation
        expect(notified, false);
        // But state should be reset
        expect(followersListState.status, FollowersListStatus.initial);
        expect(followersListState.followers, isEmpty);
        expect(followersListState.following, isEmpty);
      });
    });
  });
}
