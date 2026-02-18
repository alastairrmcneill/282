import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'saved_list_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  SavedListRepository,
  SavedListMunroRepository,
  UserState,
  Logger,
])
void main() {
  late MockSavedListRepository mockSavedListRepository;
  late MockSavedListMunroRepository mockSavedListMunroRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late SavedListState savedListState;

  late List<SavedList> sampleSavedLists;
  late AppUser sampleUser;

  setUp(() {
    // Sample user data for testing
    sampleUser = AppUser(
      uid: 'currentUser',
      displayName: 'Current User',
      searchName: 'current user',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample saved list data for testing
    sampleSavedLists = [
      SavedList(
        uid: 'list1',
        name: 'My First List',
        userId: 'currentUser',
        munroIds: [1, 2, 3],
        dateTimeCreated: DateTime(2024, 1, 1),
      ),
      SavedList(
        uid: 'list2',
        name: 'My Second List',
        userId: 'currentUser',
        munroIds: [4, 5],
        dateTimeCreated: DateTime(2024, 1, 2),
      ),
      SavedList(
        uid: 'list3',
        name: 'Empty List',
        userId: 'currentUser',
        munroIds: [],
        dateTimeCreated: DateTime(2024, 1, 3),
      ),
    ];

    mockSavedListRepository = MockSavedListRepository();
    mockSavedListMunroRepository = MockSavedListMunroRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    savedListState = SavedListState(
      mockSavedListRepository,
      mockSavedListMunroRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(sampleUser);
  });

  group('SavedListState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(savedListState.status, SavedListStatus.initial);
        expect(savedListState.error, isA<Error>());
        expect(savedListState.savedLists, isEmpty);
      });
    });

    group('createSavedList', () {
      test('should create saved list successfully', () async {
        // Arrange
        final newList = SavedList(
          uid: 'newList',
          name: 'New List',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async => newList);

        // Act
        await savedListState.createSavedList(name: 'New List');

        // Assert
        expect(savedListState.status, SavedListStatus.loaded);
        expect(savedListState.savedLists.length, 1);
        expect(savedListState.savedLists.first.name, 'New List');
        verify(mockSavedListRepository.create(savedList: anyNamed('savedList'))).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when user is not signed in', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await savedListState.createSavedList(name: 'New List');

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'You must be signed in to create a list');
        expect(savedListState.error.code, 'user-not-signed-in');
        verifyNever(mockSavedListRepository.create(savedList: anyNamed('savedList')));
      });

      test('should handle error during creation', () async {
        // Arrange
        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenThrow(Exception('Database error'));

        // Act
        await savedListState.createSavedList(name: 'New List');

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue creating your list. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleSavedLists.first;
        });

        // Act
        final future = savedListState.createSavedList(name: 'New List');

        // Assert intermediate state
        expect(savedListState.status, SavedListStatus.loading);

        // Wait for completion
        await future;
        expect(savedListState.status, SavedListStatus.loaded);
      });
    });

    group('readUserSavedLists', () {
      test('should read user saved lists successfully', () async {
        // Arrange
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid')))
            .thenAnswer((_) async => sampleSavedLists);

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(savedListState.status, SavedListStatus.loaded);
        expect(savedListState.savedLists, sampleSavedLists);
        expect(savedListState.savedLists.length, 3);
        verify(mockSavedListRepository.readFromUserUid(userUid: 'currentUser')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when user is not signed in', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'You must be signed in to create a list');
        expect(savedListState.error.code, 'user-not-signed-in');
        verifyNever(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid')));
      });

      test('should handle error during reading', () async {
        // Arrange
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid')))
            .thenThrow(Exception('Network error'));

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue reading your saved lists. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleSavedLists;
        });

        // Act
        final future = savedListState.readUserSavedLists();

        // Assert intermediate state
        expect(savedListState.status, SavedListStatus.loading);

        // Wait for completion
        await future;
        expect(savedListState.status, SavedListStatus.loaded);
      });

      test('should handle empty list from repository', () async {
        // Arrange
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid'))).thenAnswer((_) async => []);

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(savedListState.status, SavedListStatus.loaded);
        expect(savedListState.savedLists, isEmpty);
      });
    });

    group('updateSavedListName', () {
      test('should update saved list name successfully', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        when(mockSavedListRepository.update(savedList: anyNamed('savedList'))).thenAnswer((_) async => {});

        // Act
        await savedListState.updateSavedListName(savedList: updatedList);

        // Assert
        // Note: updateSavedListName doesn't set status to loaded after success
        expect(savedListState.status, SavedListStatus.loading);
        expect(savedListState.savedLists.first.name, 'Updated Name');
        verify(mockSavedListRepository.update(savedList: updatedList)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when user is not signed in', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        // Act
        await savedListState.updateSavedListName(savedList: updatedList);

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'You must be signed in to create a list');
        expect(savedListState.error.code, 'user-not-signed-in');
        verifyNever(mockSavedListRepository.update(savedList: anyNamed('savedList')));
      });

      test('should handle error during update', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        when(mockSavedListRepository.update(savedList: anyNamed('savedList'))).thenThrow(Exception('Update error'));

        // Act
        await savedListState.updateSavedListName(savedList: updatedList);

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue updating your list. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        when(mockSavedListRepository.update(savedList: anyNamed('savedList'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        // Act
        final future = savedListState.updateSavedListName(savedList: updatedList);

        // Assert intermediate state
        expect(savedListState.status, SavedListStatus.loading);

        // Wait for completion
        await future;
        // Note: updateSavedListName doesn't set status to loaded after success
        expect(savedListState.status, SavedListStatus.loading);
      });
    });

    group('deleteSavedList', () {
      test('should delete saved list successfully', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final listToDelete = sampleSavedLists.first;

        when(mockSavedListRepository.deleteFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => {});

        // Act
        await savedListState.deleteSavedList(savedList: listToDelete);

        // Assert
        expect(savedListState.savedLists.length, 2);
        expect(savedListState.savedLists.contains(listToDelete), false);
        verify(mockSavedListRepository.deleteFromUid(uid: 'list1')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during deletion', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final listToDelete = sampleSavedLists.first;

        when(mockSavedListRepository.deleteFromUid(uid: anyNamed('uid'))).thenThrow(Exception('Delete error'));

        final initialCount = savedListState.savedLists.length;

        // Act
        await savedListState.deleteSavedList(savedList: listToDelete);

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue deleting your post. Please try again.');
        // List was removed optimistically
        expect(savedListState.savedLists.length, initialCount - 1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle deleting non-existent list', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final nonExistentList = SavedList(
          uid: 'nonExistent',
          name: 'Non-existent',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        when(mockSavedListRepository.deleteFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => {});

        final initialCount = savedListState.savedLists.length;

        // Act
        await savedListState.deleteSavedList(savedList: nonExistentList);

        // Assert
        expect(savedListState.savedLists.length, initialCount);
        verify(mockSavedListRepository.deleteFromUid(uid: 'nonExistent')).called(1);
      });
    });

    group('addMunroToSavedList', () {
      test('should add munro to saved list successfully', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.last; // Empty list
        final munroId = 10;

        when(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')))
            .thenAnswer((_) async => {});

        // Act
        await savedListState.addMunroToSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(targetList.munroIds.contains(munroId), true);
        verify(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro'))).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should not add duplicate munro to saved list', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.first;
        final munroId = 1; // Already in the list

        // Act
        await savedListState.addMunroToSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        verifyNever(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')));
      });

      test('should handle error when user is not signed in', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        final targetList = sampleSavedLists.first;
        final munroId = 10;

        // Act
        await savedListState.addMunroToSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'You must be signed in to create a list');
        expect(savedListState.error.code, 'user-not-signed-in');
        verifyNever(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')));
      });

      test('should handle error during munro addition', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.last;
        final munroId = 10;

        when(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')))
            .thenThrow(Exception('Database error'));

        // Act
        await savedListState.addMunroToSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue saving your Munro. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('removeMunroFromSavedList', () {
      test('should remove munro from saved list successfully', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.first;
        final munroId = 1; // In the list

        when(mockSavedListMunroRepository.delete(
          savedListId: anyNamed('savedListId'),
          munroId: anyNamed('munroId'),
        )).thenAnswer((_) async => {});

        // Act
        await savedListState.removeMunroFromSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(targetList.munroIds.contains(munroId), false);
        verify(mockSavedListMunroRepository.delete(
          savedListId: 'list1',
          munroId: munroId,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should not remove munro that is not in the list', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.last; // Empty list
        final munroId = 10;

        // Act
        await savedListState.removeMunroFromSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        verifyNever(mockSavedListMunroRepository.delete(
          savedListId: anyNamed('savedListId'),
          munroId: anyNamed('munroId'),
        ));
      });

      test('should handle error when user is not signed in', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        final targetList = sampleSavedLists.first;
        final munroId = 1;

        // Act
        await savedListState.removeMunroFromSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'You must be signed in to create a list');
        expect(savedListState.error.code, 'user-not-signed-in');
        verifyNever(mockSavedListMunroRepository.delete(
          savedListId: anyNamed('savedListId'),
          munroId: anyNamed('munroId'),
        ));
      });

      test('should handle error during munro removal', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.first;
        final munroId = 1;

        when(mockSavedListMunroRepository.delete(
          savedListId: anyNamed('savedListId'),
          munroId: anyNamed('munroId'),
        )).thenThrow(Exception('Database error'));

        // Act
        await savedListState.removeMunroFromSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error.message, 'There was an issue removing your Munro. Please try again');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        savedListState.setStatus = SavedListStatus.loading;
        expect(savedListState.status, SavedListStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        savedListState.setError = error;

        expect(savedListState.status, SavedListStatus.error);
        expect(savedListState.error, error);
      });

      test('setSavedLists should update saved lists', () {
        savedListState.setSavedLists = sampleSavedLists;

        expect(savedListState.savedLists, sampleSavedLists);
        expect(savedListState.savedLists.length, 3);
      });
    });

    group('List Management Methods', () {
      test('addSavedList should add to saved lists', () {
        // Arrange
        final newList = SavedList(
          uid: 'newList',
          name: 'New List',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        // Act
        savedListState.addSavedList(newList);

        // Assert
        expect(savedListState.savedLists.length, 1);
        expect(savedListState.savedLists.first, newList);
      });

      test('removeSavedList should remove from saved lists', () {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final listToRemove = sampleSavedLists.first;

        // Act
        savedListState.removeSavedList(listToRemove);

        // Assert
        expect(savedListState.savedLists.length, 2);
        expect(savedListState.savedLists.contains(listToRemove), false);
      });

      test('removeSavedList should handle removing non-existent list', () {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final nonExistentList = SavedList(
          uid: 'nonExistent',
          name: 'Non-existent',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        final initialCount = savedListState.savedLists.length;

        // Act
        savedListState.removeSavedList(nonExistentList);

        // Assert
        expect(savedListState.savedLists.length, initialCount);
      });

      test('updateSavedList should update existing list', () {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        // Act
        savedListState.updateSavedList(updatedList);

        // Assert
        expect(savedListState.savedLists.first.name, 'Updated Name');
        expect(savedListState.savedLists.length, 3);
      });

      test('updateSavedList should not add new list if uid not found', () {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final newList = SavedList(
          uid: 'nonExistent',
          name: 'Non-existent',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        final initialCount = savedListState.savedLists.length;

        // Act
        savedListState.updateSavedList(newList);

        // Assert
        expect(savedListState.savedLists.length, initialCount);
      });
    });

    group('Edge Cases', () {
      test('should handle creating list with empty name', () async {
        // Arrange
        final newList = SavedList(
          uid: 'newList',
          name: '',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async => newList);

        // Act
        await savedListState.createSavedList(name: '');

        // Assert
        expect(savedListState.status, SavedListStatus.loaded);
        expect(savedListState.savedLists.first.name, '');
      });

      test('should handle list with many munros', () {
        // Arrange
        final listWithManyMunros = SavedList(
          uid: 'bigList',
          name: 'Big List',
          userId: 'currentUser',
          munroIds: List.generate(100, (index) => index),
          dateTimeCreated: DateTime.now(),
        );

        // Act
        savedListState.setSavedLists = [listWithManyMunros];

        // Assert
        expect(savedListState.savedLists.first.munroIds.length, 100);
      });

      test('should handle null uid in saved list', () {
        // Arrange
        final listWithoutUid = SavedList(
          uid: null,
          name: 'No UID List',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        // Act
        savedListState.setSavedLists = [listWithoutUid];

        // Assert
        expect(savedListState.savedLists.first.uid, isNull);
      });

      test('should handle adding munro with negative id', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.last;
        final munroId = -1;

        when(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')))
            .thenAnswer((_) async => {});

        // Act
        await savedListState.addMunroToSavedList(
          savedList: targetList,
          munroId: munroId,
        );

        // Assert
        expect(targetList.munroIds.contains(munroId), true);
      });

      test('should handle repository returning null user id', () async {
        // Arrange
        final userWithNullUid = AppUser(
          uid: null,
          displayName: 'No UID User',
        );
        when(mockUserState.currentUser).thenReturn(userWithNullUid);
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid'))).thenAnswer((_) async => []);

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(savedListState.status, SavedListStatus.loaded);
        verify(mockSavedListRepository.readFromUserUid(userUid: '')).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when creating saved list', () async {
        // Arrange
        final newList = SavedList(
          uid: 'newList',
          name: 'New List',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async => newList);

        bool notified = false;
        savedListState.addListener(() => notified = true);

        // Act
        await savedListState.createSavedList(name: 'New List');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when reading saved lists', () async {
        // Arrange
        when(mockSavedListRepository.readFromUserUid(userUid: anyNamed('userUid')))
            .thenAnswer((_) async => sampleSavedLists);

        bool notified = false;
        savedListState.addListener(() => notified = true);

        // Act
        await savedListState.readUserSavedLists();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when updating saved list name', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');

        when(mockSavedListRepository.update(savedList: anyNamed('savedList'))).thenAnswer((_) async => {});

        bool notified = false;
        savedListState.addListener(() => notified = true);

        // Act
        await savedListState.updateSavedListName(savedList: updatedList);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting saved lists', () {
        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.setSavedLists = sampleSavedLists;

        expect(notified, true);
      });

      test('should notify listeners when adding saved list', () {
        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.addSavedList(sampleSavedLists.first);

        expect(notified, true);
      });

      test('should notify listeners when removing saved list', () {
        savedListState.setSavedLists = List.from(sampleSavedLists);

        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.removeSavedList(sampleSavedLists.first);

        expect(notified, true);
      });

      test('should notify listeners when updating saved list', () {
        savedListState.setSavedLists = List.from(sampleSavedLists);

        bool notified = false;
        savedListState.addListener(() => notified = true);

        final updatedList = sampleSavedLists.first.copy(name: 'Updated Name');
        savedListState.updateSavedList(updatedList);

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.setStatus = SavedListStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should not notify listeners when removing non-existent list', () {
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final nonExistentList = SavedList(
          uid: 'nonExistent',
          name: 'Non-existent',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        bool notified = false;
        savedListState.addListener(() => notified = true);

        savedListState.removeSavedList(nonExistentList);

        expect(notified, false);
      });
    });

    group('Complex Scenarios', () {
      test('should handle multiple operations in sequence', () async {
        // Arrange
        final list1 = SavedList(
          uid: 'list1',
          name: 'List 1',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );
        final list2 = SavedList(
          uid: 'list2',
          name: 'List 2',
          userId: 'currentUser',
          munroIds: [],
          dateTimeCreated: DateTime.now(),
        );

        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async => list1);

        // Act - Create first list
        await savedListState.createSavedList(name: 'List 1');
        expect(savedListState.savedLists.length, 1);

        // Create second list
        when(mockSavedListRepository.create(savedList: anyNamed('savedList'))).thenAnswer((_) async => list2);
        await savedListState.createSavedList(name: 'List 2');
        expect(savedListState.savedLists.length, 2);

        // Update first list
        final updatedList1 = list1.copy(name: 'Updated List 1');
        when(mockSavedListRepository.update(savedList: anyNamed('savedList'))).thenAnswer((_) async => {});
        await savedListState.updateSavedListName(savedList: updatedList1);
        expect(savedListState.savedLists.first.name, 'Updated List 1');

        // Delete second list
        when(mockSavedListRepository.deleteFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => {});
        await savedListState.deleteSavedList(savedList: list2);
        expect(savedListState.savedLists.length, 1);

        // Assert final state - update leaves status as loading
        expect(savedListState.status, SavedListStatus.loading);
        expect(savedListState.savedLists.first.name, 'Updated List 1');
      });

      test('should handle multiple munro additions and removals', () async {
        // Arrange
        savedListState.setSavedLists = List.from(sampleSavedLists);
        final targetList = sampleSavedLists.last; // Empty list

        when(mockSavedListMunroRepository.create(savedListMunro: anyNamed('savedListMunro')))
            .thenAnswer((_) async => {});
        when(mockSavedListMunroRepository.delete(
          savedListId: anyNamed('savedListId'),
          munroId: anyNamed('munroId'),
        )).thenAnswer((_) async => {});

        // Act - Add munros
        await savedListState.addMunroToSavedList(savedList: targetList, munroId: 1);
        await savedListState.addMunroToSavedList(savedList: targetList, munroId: 2);
        await savedListState.addMunroToSavedList(savedList: targetList, munroId: 3);

        // Assert after additions
        expect(targetList.munroIds.length, 3);
        expect(targetList.munroIds, [1, 2, 3]);

        // Act - Remove a munro
        await savedListState.removeMunroFromSavedList(savedList: targetList, munroId: 2);

        // Assert after removal
        expect(targetList.munroIds.length, 2);
        expect(targetList.munroIds, [1, 3]);
      });
    });
  });
}
