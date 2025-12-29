import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'user_search_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  UserRepository,
  UserState,
  Logger,
])
void main() {
  late MockUserRepository mockUserRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late UserSearchState userSearchState;

  late AppUser currentUser;
  late List<AppUser> sampleUsers;

  setUp(() {
    // Sample user data for testing
    currentUser = AppUser(
      uid: 'currentUser',
      displayName: 'Current User',
      searchName: 'current user',
    );

    sampleUsers = [
      AppUser(
        uid: 'user1',
        displayName: 'John Doe',
        searchName: 'john doe',
        profilePictureURL: 'https://example.com/user1.jpg',
      ),
      AppUser(
        uid: 'user2',
        displayName: 'Jane Smith',
        searchName: 'jane smith',
        profilePictureURL: 'https://example.com/user2.jpg',
      ),
      AppUser(
        uid: 'user3',
        displayName: 'Bob Johnson',
        searchName: 'bob johnson',
        profilePictureURL: null,
      ),
    ];

    mockUserRepository = MockUserRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    userSearchState = UserSearchState(
      mockUserRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(currentUser);
    when(mockUserState.blockedUsers).thenReturn([]);
  });

  group('UserSearchState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(userSearchState.status, SearchStatus.initial);
        expect(userSearchState.error, isA<Error>());
        expect(userSearchState.users, isEmpty);
      });
    });

    group('search', () {
      test('should search users successfully', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleUsers);

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        expect(userSearchState.status, SearchStatus.loaded);
        expect(userSearchState.users, sampleUsers);
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should convert search query to lowercase', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleUsers);

        // Act
        await userSearchState.search(query: 'JOHN DOE');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john doe',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should exclude blocked users when searching', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleUsers);

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should return early if currentUser is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        verifyNever(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
        expect(userSearchState.status, SearchStatus.initial);
      });

      test('should handle error during search', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Network error'));

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        expect(userSearchState.status, SearchStatus.error);
        expect(userSearchState.error.message, 'There was an issue with the search. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleUsers;
        });

        // Act
        final future = userSearchState.search(query: 'John');

        // Assert intermediate state
        expect(userSearchState.status, SearchStatus.loading);

        // Wait for completion
        await future;
        expect(userSearchState.status, SearchStatus.loaded);
      });

      test('should handle empty search results', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.search(query: 'NonExistent');

        // Assert
        expect(userSearchState.status, SearchStatus.loaded);
        expect(userSearchState.users, isEmpty);
      });
    });

    group('paginateSearch', () {
      test('should paginate search results successfully', () async {
        // Set initial users
        userSearchState.setUsers = List.from(sampleUsers);

        // Arrange
        final additionalUsers = [
          AppUser(
            uid: 'user4',
            displayName: 'Alice Brown',
            searchName: 'alice brown',
            profilePictureURL: 'https://example.com/user4.jpg',
          ),
        ];

        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalUsers);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        expect(userSearchState.status, SearchStatus.loaded);
        expect(userSearchState.users.length, 4);
        expect(userSearchState.users.last.displayName, 'Alice Brown');
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should convert search query to lowercase when paginating', () async {
        // Arrange
        userSearchState.setUsers = List.from(sampleUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.paginateSearch(query: 'JOHN');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: [],
          offset: 3,
        )).called(1);
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        userSearchState.setUsers = List.from(sampleUsers);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should return early if currentUser is null', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        verifyNever(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
      });

      test('should handle error during pagination', () async {
        // Arrange
        userSearchState.setUsers = List.from(sampleUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial user count
        final initialCount = userSearchState.users.length;

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        expect(userSearchState.status, SearchStatus.error);
        expect(userSearchState.error.message, 'There was an issue with the search. Please try again.');
        // Original users should remain unchanged
        expect(userSearchState.users.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        userSearchState.setUsers = List.from(sampleUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = userSearchState.paginateSearch(query: 'John');

        // Assert intermediate state
        expect(userSearchState.status, SearchStatus.paginating);

        // Wait for completion
        await future;
        expect(userSearchState.status, SearchStatus.loaded);
      });

      test('should handle empty pagination results', () async {
        // Arrange
        userSearchState.setUsers = List.from(sampleUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        expect(userSearchState.status, SearchStatus.loaded);
        expect(userSearchState.users.length, 3);
      });
    });

    group('clearSearch', () {
      test('should clear search results and reset status', () {
        // Arrange
        userSearchState.setUsers = sampleUsers;
        userSearchState.setStatus = SearchStatus.loaded;

        // Act
        userSearchState.clearSearch();

        // Assert
        expect(userSearchState.status, SearchStatus.initial);
        expect(userSearchState.users, isEmpty);
      });

      test('should clear search results when already empty', () {
        // Arrange - users already empty
        expect(userSearchState.users, isEmpty);

        // Act
        userSearchState.clearSearch();

        // Assert
        expect(userSearchState.status, SearchStatus.initial);
        expect(userSearchState.users, isEmpty);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        userSearchState.setStatus = SearchStatus.loading;
        expect(userSearchState.status, SearchStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        userSearchState.setError = error;

        expect(userSearchState.status, SearchStatus.error);
        expect(userSearchState.error, error);
      });

      test('setUsers should update users list', () {
        userSearchState.setUsers = sampleUsers;

        expect(userSearchState.users, sampleUsers);
        expect(userSearchState.users.length, 3);
      });

      test('addUsers should append to existing users', () {
        userSearchState.setUsers = [sampleUsers.first];

        userSearchState.addUsers = [sampleUsers[1], sampleUsers[2]];

        expect(userSearchState.users.length, 3);
        expect(userSearchState.users[0], sampleUsers[0]);
        expect(userSearchState.users[1], sampleUsers[1]);
        expect(userSearchState.users[2], sampleUsers[2]);
      });
    });

    group('Edge Cases', () {
      test('should handle empty users list on pagination', () async {
        // Arrange - start with empty list
        expect(userSearchState.users, isEmpty);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleUsers);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        expect(userSearchState.users, sampleUsers);
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final userWithNullURL = AppUser(
          uid: 'user5',
          displayName: 'No Picture User',
          searchName: 'no picture user',
          profilePictureURL: null,
        );

        // Act
        userSearchState.setUsers = [userWithNullURL];

        // Assert
        expect(userSearchState.users.first.profilePictureURL, isNull);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.search(query: 'NonExistent');

        // Assert
        expect(userSearchState.status, SearchStatus.loaded);
        expect(userSearchState.users, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: 'john',
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle empty string search query', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.search(query: '');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: '',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle whitespace-only search query', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await userSearchState.search(query: '   ');

        // Assert
        verify(mockUserRepository.readUsersByName(
          searchTerm: '   ',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when searching', () async {
        // Arrange
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleUsers);

        bool notified = false;
        userSearchState.addListener(() => notified = true);

        // Act
        await userSearchState.search(query: 'John');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating', () async {
        // Arrange
        userSearchState.setUsers = sampleUsers;
        when(mockUserRepository.readUsersByName(
          searchTerm: anyNamed('searchTerm'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        userSearchState.addListener(() => notified = true);

        // Act
        await userSearchState.paginateSearch(query: 'John');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when clearing search', () {
        userSearchState.setUsers = sampleUsers;

        bool notified = false;
        userSearchState.addListener(() => notified = true);

        userSearchState.clearSearch();

        expect(notified, true);
      });

      test('should notify listeners when setting users', () {
        bool notified = false;
        userSearchState.addListener(() => notified = true);

        userSearchState.setUsers = sampleUsers;

        expect(notified, true);
      });

      test('should notify listeners when adding users', () {
        userSearchState.setUsers = [sampleUsers.first];

        bool notified = false;
        userSearchState.addListener(() => notified = true);

        userSearchState.addUsers = [sampleUsers[1]];

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        userSearchState.addListener(() => notified = true);

        userSearchState.setStatus = SearchStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        userSearchState.addListener(() => notified = true);

        userSearchState.setError = Error(message: 'test error');

        expect(notified, true);
      });
    });
  });
}
