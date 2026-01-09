import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'group_filter_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  FollowersRepository,
  MunroCompletionsRepository,
  UserState,
  MunroState,
  Logger,
])
void main() {
  late MockFollowersRepository mockFollowersRepository;
  late MockMunroCompletionsRepository mockMunroCompletionsRepository;
  late MockUserState mockUserState;
  late MockMunroState mockMunroState;
  late MockLogger mockLogger;
  late GroupFilterState groupFilterState;

  late List<FollowingRelationship> sampleFriends;
  late List<MunroCompletion> sampleMunroCompletions;
  late AppUser sampleCurrentUser;

  setUp(() {
    // Sample current user for testing
    sampleCurrentUser = AppUser(
      uid: 'currentUserId',
      displayName: 'Current User',
      searchName: 'current user',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample following relationship data for testing
    sampleFriends = [
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'friend1',
        targetDisplayName: 'Friend One',
        targetProfilePictureURL: 'https://example.com/friend1.jpg',
        targetSearchName: 'friend one',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'friend2',
        targetDisplayName: 'Friend Two',
        targetProfilePictureURL: 'https://example.com/friend2.jpg',
        targetSearchName: 'friend two',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
      FollowingRelationship(
        sourceId: 'currentUserId',
        targetId: 'friend3',
        targetDisplayName: 'Friend Three',
        targetProfilePictureURL: null,
        targetSearchName: 'friend three',
        sourceDisplayName: 'Current User',
        sourceProfilePictureURL: 'https://example.com/current.jpg',
      ),
    ];

    // Sample munro completions for testing
    sampleMunroCompletions = [
      MunroCompletion(
        id: '1',
        userId: 'friend1',
        munroId: 101,
        dateTimeCompleted: DateTime(2024, 1, 1),
      ),
      MunroCompletion(
        id: '2',
        userId: 'friend2',
        munroId: 102,
        dateTimeCompleted: DateTime(2024, 1, 2),
      ),
      MunroCompletion(
        id: '3',
        userId: 'currentUserId',
        munroId: 101,
        dateTimeCompleted: DateTime(2024, 1, 3),
      ),
    ];

    mockFollowersRepository = MockFollowersRepository();
    mockMunroCompletionsRepository = MockMunroCompletionsRepository();
    mockUserState = MockUserState();
    mockMunroState = MockMunroState();
    mockLogger = MockLogger();

    groupFilterState = GroupFilterState(
      mockUserState,
      mockFollowersRepository,
      mockMunroState,
      mockMunroCompletionsRepository,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    groupFilterState.reset();
  });

  group('GroupFilterState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(groupFilterState.status, GroupFilterStatus.initial);
        expect(groupFilterState.error, isA<Error>());
        expect(groupFilterState.friends, isEmpty);
        expect(groupFilterState.selectedFriendsUids, isEmpty);
      });
    });

    group('getInitialFriends', () {
      test('should load friends successfully', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFriends);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.loaded);
        expect(groupFilterState.friends, sampleFriends);
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
        )).thenAnswer((_) async => sampleFriends);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUserId',
          excludedUserIds: blockedUsers,
        )).called(1);
      });

      test('should handle error during loading friends', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenThrow(Exception('Network error'));

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.error);
        expect(groupFilterState.error.message, 'There was an issue. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should not load if current user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        verifyNever(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        ));
        expect(groupFilterState.status, GroupFilterStatus.initial);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleFriends;
        });

        // Act
        final future = groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert intermediate state
        expect(groupFilterState.status, GroupFilterStatus.loading);

        // Wait for completion
        await future;
        expect(groupFilterState.status, GroupFilterStatus.loaded);
      });
    });

    group('search', () {
      test('should search friends successfully', () async {
        // Arrange
        final searchResults = [sampleFriends.first];
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async => searchResults);

        // Act
        await groupFilterState.search(query: 'friend one');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.loaded);
        expect(groupFilterState.friends, searchResults);
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend one',
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should convert search query to lowercase', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.search(query: 'FRIEND ONE');

        // Assert
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend one',
        )).called(1);
      });

      test('should handle error during search', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenThrow(Exception('Search error'));

        // Act
        await groupFilterState.search(query: 'friend');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.error);
        expect(groupFilterState.error.message, 'There was an issue with the search. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should not search if current user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await groupFilterState.search(query: 'friend');

        // Assert
        verifyNever(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        ));
        expect(groupFilterState.status, GroupFilterStatus.initial);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = groupFilterState.search(query: 'friend');

        // Assert intermediate state
        expect(groupFilterState.status, GroupFilterStatus.loading);

        // Wait for completion
        await future;
        expect(groupFilterState.status, GroupFilterStatus.loaded);
      });
    });

    group('paginateSearch', () {
      test('should paginate search results successfully', () async {
        // Set initial friends - use a copy to avoid mutating sampleFriends
        groupFilterState.setFriends = [sampleFriends.first];

        // Arrange
        final additionalFriends = [sampleFriends[1], sampleFriends[2]];
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalFriends);

        // Act
        await groupFilterState.paginateSearch(query: 'friend');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.loaded);
        expect(groupFilterState.friends.length, 3);
        expect(groupFilterState.friends[0], sampleFriends[0]);
        expect(groupFilterState.friends[1], sampleFriends[1]);
        expect(groupFilterState.friends[2], sampleFriends[2]);
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend',
          offset: 1,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should convert search query to lowercase during pagination', () async {
        // Arrange
        groupFilterState.setFriends = [sampleFriends.first];
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.paginateSearch(query: 'FRIEND TWO');

        // Assert
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend two',
          offset: 1,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        groupFilterState.setFriends = List.from(sampleFriends);
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial friend count
        final initialCount = groupFilterState.friends.length;

        // Act
        await groupFilterState.paginateSearch(query: 'friend');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.error);
        expect(groupFilterState.error.message, 'There was an issue loading more. Please try again.');
        // Original friends should remain unchanged
        expect(groupFilterState.friends.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should not paginate if current user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await groupFilterState.paginateSearch(query: 'friend');

        // Assert
        verifyNever(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        ));
        expect(groupFilterState.status, GroupFilterStatus.initial);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        groupFilterState.setFriends = [sampleFriends.first];
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = groupFilterState.paginateSearch(query: 'friend');

        // Assert intermediate state
        expect(groupFilterState.status, GroupFilterStatus.paginating);

        // Wait for completion
        await future;
        expect(groupFilterState.status, GroupFilterStatus.loaded);
      });
    });

    group('clearSearch', () {
      test('should clear search results and reset status', () {
        // Arrange
        groupFilterState.setFriends = sampleFriends;
        groupFilterState.setStatus = GroupFilterStatus.loaded;

        // Act
        groupFilterState.clearSearch();

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.initial);
        expect(groupFilterState.friends, isEmpty);
      });
    });

    group('addSelectedFriend', () {
      test('should add friend uid to selection', () {
        // Act
        groupFilterState.addSelectedFriend(uid: 'friend1');

        // Assert
        expect(groupFilterState.selectedFriendsUids, contains('friend1'));
        expect(groupFilterState.selectedFriendsUids.length, 1);
      });

      test('should add multiple friends to selection', () {
        // Act
        groupFilterState.addSelectedFriend(uid: 'friend1');
        groupFilterState.addSelectedFriend(uid: 'friend2');
        groupFilterState.addSelectedFriend(uid: 'friend3');

        // Assert
        expect(groupFilterState.selectedFriendsUids, ['friend1', 'friend2', 'friend3']);
        expect(groupFilterState.selectedFriendsUids.length, 3);
      });
    });

    group('removeSelectedFriend', () {
      test('should remove friend uid from selection', () {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');
        groupFilterState.addSelectedFriend(uid: 'friend2');

        // Act
        groupFilterState.removeSelectedFriend(uid: 'friend1');

        // Assert
        expect(groupFilterState.selectedFriendsUids, ['friend2']);
        expect(groupFilterState.selectedFriendsUids.length, 1);
      });

      test('should handle removing uid that is not in selection', () {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');

        // Act
        groupFilterState.removeSelectedFriend(uid: 'friend2');

        // Assert
        expect(groupFilterState.selectedFriendsUids, ['friend1']);
        expect(groupFilterState.selectedFriendsUids.length, 1);
      });

      test('should handle removing from empty selection', () {
        // Act
        groupFilterState.removeSelectedFriend(uid: 'friend1');

        // Assert
        expect(groupFilterState.selectedFriendsUids, isEmpty);
      });
    });

    group('clearSelection', () {
      test('should clear selected friends and munro filter', () {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');
        groupFilterState.addSelectedFriend(uid: 'friend2');

        // Act
        groupFilterState.clearSelection();

        // Assert
        expect(groupFilterState.selectedFriendsUids, isEmpty);
        verify(mockMunroState.setGroupFilterMunroIds = []).called(1);
      });
    });

    group('filterMunrosBySelection', () {
      test('should filter munros by selected friends successfully', () async {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');
        groupFilterState.addSelectedFriend(uid: 'friend2');

        when(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: anyNamed('userIds'),
        )).thenAnswer((_) async => sampleMunroCompletions);

        // Act
        await groupFilterState.filterMunrosBySelection();

        // Assert
        verify(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: ['friend1', 'friend2', 'currentUserId'],
        )).called(1);
        verify(mockMunroState.setGroupFilterMunroIds = [101, 102]).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should include current user in filter query', () async {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');

        when(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: anyNamed('userIds'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.filterMunrosBySelection();

        // Assert
        final captured = verify(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: captureAnyNamed('userIds'),
        )).captured.first as List<String>;

        expect(captured, contains('currentUserId'));
        expect(captured, contains('friend1'));
      });

      test('should handle duplicate munro IDs', () async {
        // Arrange
        groupFilterState.addSelectedFriend(uid: 'friend1');

        final duplicateMunroCompletions = [
          MunroCompletion(
            id: '1',
            userId: 'friend1',
            munroId: 101,
            dateTimeCompleted: DateTime(2024, 1, 1),
          ),
          MunroCompletion(
            id: '2',
            userId: 'friend1',
            munroId: 101,
            dateTimeCompleted: DateTime(2024, 1, 2),
          ),
        ];

        when(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: anyNamed('userIds'),
        )).thenAnswer((_) async => duplicateMunroCompletions);

        // Act
        await groupFilterState.filterMunrosBySelection();

        // Assert
        verify(mockMunroState.setGroupFilterMunroIds = [101]).called(1);
      });

      test('should not filter if current user is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await groupFilterState.filterMunrosBySelection();

        // Assert
        verifyNever(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: anyNamed('userIds'),
        ));
      });

      test('should handle empty selection', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: anyNamed('userIds'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.filterMunrosBySelection();

        // Assert
        verify(mockMunroCompletionsRepository.getMunroCompletionsFromUserList(
          userIds: ['currentUserId'],
        )).called(1);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        groupFilterState.setFriends = sampleFriends;
        groupFilterState.setStatus = GroupFilterStatus.loaded;
        groupFilterState.addSelectedFriend(uid: 'friend1');
        groupFilterState.addSelectedFriend(uid: 'friend2');

        // Act
        groupFilterState.reset();

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.initial);
        expect(groupFilterState.error, isA<Error>());
        expect(groupFilterState.friends, isEmpty);
        expect(groupFilterState.selectedFriendsUids, isEmpty);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        groupFilterState.setStatus = GroupFilterStatus.loading;
        expect(groupFilterState.status, GroupFilterStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        groupFilterState.setError = error;

        expect(groupFilterState.status, GroupFilterStatus.error);
        expect(groupFilterState.error, error);
      });

      test('setFriends should update friends list', () {
        groupFilterState.setFriends = sampleFriends;

        expect(groupFilterState.friends, sampleFriends);
        expect(groupFilterState.friends.length, 3);
      });

      test('addFriends should append to existing friends', () {
        groupFilterState.setFriends = [sampleFriends.first];

        groupFilterState.addFriends = [sampleFriends[1], sampleFriends[2]];

        expect(groupFilterState.friends.length, 3);
        expect(groupFilterState.friends[0], sampleFriends[0]);
        expect(groupFilterState.friends[1], sampleFriends[1]);
        expect(groupFilterState.friends[2], sampleFriends[2]);
      });
    });

    group('Edge Cases', () {
      test('should handle empty friends list on pagination', () async {
        // Arrange - start with empty list
        expect(groupFilterState.friends, isEmpty);
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleFriends);

        // Act
        await groupFilterState.paginateSearch(query: 'friend');

        // Assert
        expect(groupFilterState.friends, sampleFriends);
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend',
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final friendWithNullURL = FollowingRelationship(
          sourceId: 'currentUserId',
          targetId: 'friend4',
          targetDisplayName: 'Friend Four',
          targetProfilePictureURL: null,
          targetSearchName: 'friend four',
          sourceDisplayName: 'Current User',
          sourceProfilePictureURL: null,
        );

        // Act
        groupFilterState.setFriends = [friendWithNullURL];

        // Assert
        expect(groupFilterState.friends.first.targetProfilePictureURL, isNull);
        expect(groupFilterState.friends.first.sourceProfilePictureURL, isNull);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        expect(groupFilterState.status, GroupFilterStatus.loaded);
        expect(groupFilterState.friends, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        verify(mockFollowersRepository.getFollowingFromUid(
          sourceId: 'currentUserId',
          excludedUserIds: blockedUsers,
        )).called(1);
      });

      test('should handle search with empty query', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async => sampleFriends);

        // Act
        await groupFilterState.search(query: '');

        // Assert
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: '',
        )).called(1);
      });

      test('should handle search with special characters', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async => []);

        // Act
        await groupFilterState.search(query: 'Friend@#\$%');

        // Assert
        verify(mockFollowersRepository.searchFollowing(
          sourceId: 'currentUserId',
          searchTerm: 'friend@#\$%',
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading friends', () async {
        // Arrange
        when(mockFollowersRepository.getFollowingFromUid(
          sourceId: anyNamed('sourceId'),
          excludedUserIds: anyNamed('excludedUserIds'),
        )).thenAnswer((_) async => sampleFriends);

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        // Act
        await groupFilterState.getInitialFriends(userId: 'currentUserId');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when searching', () async {
        // Arrange
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        // Act
        await groupFilterState.search(query: 'friend');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating search', () async {
        // Arrange
        groupFilterState.setFriends = [sampleFriends.first];
        when(mockFollowersRepository.searchFollowing(
          sourceId: anyNamed('sourceId'),
          searchTerm: anyNamed('searchTerm'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        // Act
        await groupFilterState.paginateSearch(query: 'friend');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting friends', () {
        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.setFriends = sampleFriends;

        expect(notified, true);
      });

      test('should notify listeners when adding friends', () {
        groupFilterState.setFriends = [sampleFriends.first];

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.addFriends = [sampleFriends[1]];

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.setStatus = GroupFilterStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when adding selected friend', () {
        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.addSelectedFriend(uid: 'friend1');

        expect(notified, true);
      });

      test('should notify listeners when removing selected friend', () {
        groupFilterState.addSelectedFriend(uid: 'friend1');

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.removeSelectedFriend(uid: 'friend1');

        expect(notified, true);
      });

      test('should notify listeners when clearing selection', () {
        groupFilterState.addSelectedFriend(uid: 'friend1');

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.clearSelection();

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        groupFilterState.setFriends = sampleFriends;

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.reset();

        expect(notified, true);
      });

      test('should notify listeners when clearing search', () {
        groupFilterState.setFriends = sampleFriends;

        bool notified = false;
        groupFilterState.addListener(() => notified = true);

        groupFilterState.clearSearch();

        expect(notified, true);
      });
    });
  });
}
