import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'current_user_follower_state_test.mocks.dart';

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
  late CurrentUserFollowerState currentUserFollowerState;

  late List<FollowingRelationship> sampleFollowing;
  late AppUser currentUser;

  setUp(() {
    // Sample current user for testing
    currentUser = AppUser(
      uid: 'currentUserId',
      displayName: 'Current User',
      searchName: 'current user',
      firstName: 'Current',
      lastName: 'User',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample following relationship data for testing
    sampleFollowing = [
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'user1',
        targetDisplayName: 'User One',
        targetProfilePictureURL: 'https://example.com/user1.jpg',
        targetSearchName: 'user one',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'user2',
        targetDisplayName: 'User Two',
        targetProfilePictureURL: 'https://example.com/user2.jpg',
        targetSearchName: 'user two',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'user3',
        targetDisplayName: 'User Three',
        targetProfilePictureURL: null,
        targetSearchName: 'user three',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
    ];

    mockFollowersRepository = MockFollowersRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    currentUserFollowerState = CurrentUserFollowerState(
      mockFollowersRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(currentUser);
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    currentUserFollowerState.reset();
  });

  group('CurrentUserFollowerState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.initial);
        expect(currentUserFollowerState.error, isA<Error>());
      });
    });

    group('isFollowing', () {
      test('should return false when not following user', () {
        expect(currentUserFollowerState.isFollowing('user1'), false);
      });

      test('should return true when following user', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.isFollowing('user1'), true);
        expect(currentUserFollowerState.isFollowing('user2'), true);
        expect(currentUserFollowerState.isFollowing('user3'), true);
        expect(currentUserFollowerState.isFollowing('user4'), false);
      });
    });

    group('loadInitial', () {
      test('should load following successfully', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('user1'), true);
        expect(currentUserFollowerState.isFollowing('user2'), true);
        expect(currentUserFollowerState.isFollowing('user3'), true);
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUserId',
          excludedUserIds: [],
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUserId',
          excludedUserIds: blockedUsers,
        )).called(1);
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        verifyNever(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        ));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenThrow(Exception('Network error'));

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.error);
        expect(currentUserFollowerState.error.message, 'There was an issue loading your followers. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleFollowing;
        });

        // Act
        final future = currentUserFollowerState.loadInitial();

        // Assert intermediate state
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loading);

        // Wait for completion
        await future;
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
      });

      test('should handle empty following list', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('user1'), false);
      });
    });

    group('followUser', () {
      test('should follow user successfully', () async {
        // Arrange
        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenAnswer((_) async => {});

        // Act
        await currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('newUser'), true);
        verify(mockFollowersRepository.create(
          followingRelationship: argThat(
            isA<FollowingRelationship>()
                .having((r) => r.sourceId, 'sourceId', 'currentUserId')
                .having((r) => r.targetId, 'targetId', 'newUser'),
            named: 'followingRelationship',
          ),
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert
        verifyNever(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        ));
      });

      test('should handle error during follow', () async {
        // Arrange
        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenThrow(Exception('Network error'));

        // Act
        await currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.error);
        expect(currentUserFollowerState.error.message, 'There was an issue following this user. Please try again.');
        expect(currentUserFollowerState.isFollowing('newUser'), false);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return;
        });

        // Act
        final future = currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert intermediate state
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loading);

        // Wait for completion
        await future;
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
      });

      test('should maintain existing following when adding new', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenAnswer((_) async => {});

        // Act
        await currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert
        expect(currentUserFollowerState.isFollowing('user1'), true);
        expect(currentUserFollowerState.isFollowing('user2'), true);
        expect(currentUserFollowerState.isFollowing('user3'), true);
        expect(currentUserFollowerState.isFollowing('newUser'), true);
      });
    });

    group('unfollowUser', () {
      test('should unfollow user successfully', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenAnswer((_) async => {});

        // Act
        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('user1'), false);
        expect(currentUserFollowerState.isFollowing('user2'), true);
        expect(currentUserFollowerState.isFollowing('user3'), true);
        verify(mockFollowersRepository.delete(
          sourceId: 'currentUserId',
          targetId: 'user1',
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');

        // Assert
        verifyNever(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        ));
      });

      test('should handle error during unfollow', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenThrow(Exception('Network error'));

        // Act
        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.error);
        expect(currentUserFollowerState.error.message, 'There was an issue unfollowing this user. Please try again.');
        // User should still be in following list after error
        expect(currentUserFollowerState.isFollowing('user1'), true);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return;
        });

        // Act
        final future = currentUserFollowerState.unfollowUser(targetUserId: 'user1');

        // Assert intermediate state
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loading);

        // Wait for completion
        await future;
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
      });

      test('should handle unfollowing user that is not followed', () async {
        // Arrange
        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenAnswer((_) async => {});

        // Act
        await currentUserFollowerState.unfollowUser(targetUserId: 'unknownUser');

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('unknownUser'), false);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        currentUserFollowerState.setStatus = CurrentUserFollowerStatus.loading;
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        currentUserFollowerState.setError = error;

        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.error);
        expect(currentUserFollowerState.error, error);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('user1'), true);

        // Act
        currentUserFollowerState.reset();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.initial);
        expect(currentUserFollowerState.error, isA<Error>());
        expect(currentUserFollowerState.isFollowing('user1'), false);
        expect(currentUserFollowerState.isFollowing('user2'), false);
        expect(currentUserFollowerState.isFollowing('user3'), false);
      });
    });

    group('Edge Cases', () {
      test('should handle empty following list from repository', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('anyUser'), false);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUserId',
          excludedUserIds: blockedUsers,
        )).called(1);
      });

      test('should handle following and unfollowing same user multiple times', () async {
        // Arrange
        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenAnswer((_) async => {});
        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenAnswer((_) async => {});

        // Act & Assert
        await currentUserFollowerState.followUser(targetUserId: 'user1');
        expect(currentUserFollowerState.isFollowing('user1'), true);

        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');
        expect(currentUserFollowerState.isFollowing('user1'), false);

        await currentUserFollowerState.followUser(targetUserId: 'user1');
        expect(currentUserFollowerState.isFollowing('user1'), true);

        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');
        expect(currentUserFollowerState.isFollowing('user1'), false);
      });

      test('should handle null profile picture URLs in following relationships', () async {
        // Arrange
        final followingWithNullURL = [
          FollowingRelationship(
            sourceId: 'currentUserId',
            targetId: 'user4',
            targetDisplayName: 'User Four',
            targetProfilePictureURL: null,
            targetSearchName: 'user four',
            sourceDisplayName: 'Current User',
            sourceProfilePictureURL: null,
          ),
        ];
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => followingWithNullURL);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.loaded);
        expect(currentUserFollowerState.isFollowing('user4'), true);
      });

      test('should handle current user with null uid', () async {
        // Arrange
        final userWithNullUid = AppUser(
          uid: null,
          displayName: 'Current User',
        );
        when(mockUserState.currentUser).thenReturn(userWithNullUid);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: '',
          excludedUserIds: [],
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when following user', () async {
        // Arrange
        when(mockFollowersRepository.create(
          followingRelationship: anyNamed('followingRelationship'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        // Act
        await currentUserFollowerState.followUser(targetUserId: 'newUser');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when unfollowing user', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);
        await currentUserFollowerState.loadInitial();

        when(mockFollowersRepository.delete(
          sourceId: anyNamed('sourceId'),
          targetId: anyNamed('targetId'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        // Act
        await currentUserFollowerState.unfollowUser(targetUserId: 'user1');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        currentUserFollowerState.setStatus = CurrentUserFollowerStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        currentUserFollowerState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should not notify listeners when resetting', () {
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFollowing);

        bool notified = false;
        currentUserFollowerState.addListener(() => notified = true);

        currentUserFollowerState.reset();

        // reset() does not notify listeners
        expect(notified, false);
        // But state should be reset
        expect(currentUserFollowerState.status, CurrentUserFollowerStatus.initial);
        expect(currentUserFollowerState.isFollowing('user1'), false);
      });

      test('should notify listeners multiple times during async operation', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return sampleFollowing;
        });

        int notifyCount = 0;
        currentUserFollowerState.addListener(() => notifyCount++);

        // Act
        await currentUserFollowerState.loadInitial();

        // Assert - should notify at least twice (loading and loaded)
        expect(notifyCount, greaterThanOrEqualTo(2));
      });
    });
  });
}
