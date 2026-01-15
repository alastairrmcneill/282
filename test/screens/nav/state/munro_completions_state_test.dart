import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'munro_completions_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  MunroCompletionsRepository,
  UserState,
  Analytics,
  Logger,
])
void main() {
  late MockMunroCompletionsRepository mockMunroCompletionsRepository;
  late MockUserState mockUserState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late MunroCompletionState munroCompletionState;

  late List<MunroCompletion> sampleMunroCompletions;
  late AppUser sampleUser;

  setUp(() {
    // Sample user for testing
    sampleUser = AppUser(
      uid: 'testUserId',
      displayName: 'Test User',
    );

    // Sample munro completion data for testing
    sampleMunroCompletions = [
      MunroCompletion(
        id: 'completion1',
        userId: 'testUserId',
        munroId: 1,
        postId: 'post1',
        dateTimeCompleted: DateTime(2024, 6, 15, 10, 30),
      ),
      MunroCompletion(
        id: 'completion2',
        userId: 'testUserId',
        munroId: 2,
        postId: 'post1',
        dateTimeCompleted: DateTime(2024, 6, 15, 14, 45),
      ),
      MunroCompletion(
        id: 'completion3',
        userId: 'testUserId',
        munroId: 3,
        postId: null,
        dateTimeCompleted: DateTime(2024, 7, 20, 9, 0),
      ),
    ];

    mockMunroCompletionsRepository = MockMunroCompletionsRepository();
    mockUserState = MockUserState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    // Default mock behavior for UserState - must be set before creating state
    when(mockUserState.currentUser).thenReturn(sampleUser);

    munroCompletionState = MunroCompletionState(
      mockMunroCompletionsRepository,
      mockUserState,
      mockAnalytics,
      mockLogger,
    );

    // Reset the state to ensure clean slate for each test
    munroCompletionState.reset();
  });

  group('MunroCompletionState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(munroCompletionState.status, MunroCompletionsStatus.initial);
        expect(munroCompletionState.error, isA<Error>());
        expect(munroCompletionState.munroCompletions, isEmpty);
        expect(munroCompletionState.completedMunroIds, isEmpty);
      });
    });

    group('loadUserMunroCompletions', () {
      test('should load munro completions successfully', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.loaded);
        expect(munroCompletionState.munroCompletions, sampleMunroCompletions);
        expect(munroCompletionState.completedMunroIds, {1, 2, 3});
        verify(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: 'testUserId',
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when user is not logged in', () async {
        // Arrange
        reset(mockUserState);
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'You must be logged in to load munro completions.');
        verifyNever(mockMunroCompletionsRepository.getUserMunroCompletions(userId: anyNamed('userId')));
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Network error'));

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'There was an issue loading the munro completions');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleMunroCompletions;
        });

        // Act
        final future = munroCompletionState.loadUserMunroCompletions();

        // Assert intermediate state
        expect(munroCompletionState.status, MunroCompletionsStatus.loading);

        // Wait for completion
        await future;
        expect(munroCompletionState.status, MunroCompletionsStatus.loaded);
      });

      test('should handle empty completions list', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => []);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.loaded);
        expect(munroCompletionState.munroCompletions, isEmpty);
        expect(munroCompletionState.completedMunroIds, isEmpty);
      });
    });

    group('addBulkCompletions', () {
      test('should add bulk completions successfully', () async {
        // Arrange
        final newCompletions = [
          MunroCompletion(
            userId: 'testUserId',
            munroId: 4,
            postId: 'post2',
            dateTimeCompleted: DateTime(2024, 8, 1, 11, 0),
          ),
          MunroCompletion(
            userId: 'testUserId',
            munroId: 5,
            postId: 'post2',
            dateTimeCompleted: DateTime(2024, 8, 1, 15, 30),
          ),
        ];
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.addBulkCompletions(munroCompletions: newCompletions);

        // Assert
        expect(munroCompletionState.munroCompletions, newCompletions);
        expect(munroCompletionState.completedMunroIds, {4, 5});
        verify(mockMunroCompletionsRepository.create(newCompletions)).called(1);
        verify(mockAnalytics.track(
          AnalyticsEvent.bulkMunroCompletionsAdded,
          props: {AnalyticsProp.munroCompletionsAdded: 2},
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should append to existing completions', () async {
        // Arrange - start with some existing completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => [sampleMunroCompletions.first]);
        await munroCompletionState.loadUserMunroCompletions();

        final newCompletions = [
          MunroCompletion(
            userId: 'testUserId',
            munroId: 4,
            postId: 'post3',
            dateTimeCompleted: DateTime(2024, 9, 1, 10, 0),
          ),
        ];
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.addBulkCompletions(munroCompletions: newCompletions);

        // Assert
        expect(munroCompletionState.munroCompletions.length, 2);
        expect(munroCompletionState.completedMunroIds, {1, 4});
      });

      test('should handle error when user is not logged in', () async {
        // Arrange
        reset(mockUserState);
        when(mockUserState.currentUser).thenReturn(null);
        final newCompletions = [
          MunroCompletion(
            userId: 'testUserId',
            munroId: 4,
            postId: 'post2',
            dateTimeCompleted: DateTime.now(),
          ),
        ];

        // Act
        await munroCompletionState.addBulkCompletions(munroCompletions: newCompletions);

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'You must be logged in to add munro completions.');
        verifyNever(mockMunroCompletionsRepository.create(any));
        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });

      test('should handle error during creation', () async {
        // Arrange
        final newCompletions = [
          MunroCompletion(
            userId: 'testUserId',
            munroId: 4,
            postId: 'post2',
            dateTimeCompleted: DateTime.now(),
          ),
        ];
        when(mockMunroCompletionsRepository.create(any)).thenThrow(Exception('Database error'));

        // Act
        await munroCompletionState.addBulkCompletions(munroCompletions: newCompletions);

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'There was an issue adding the munro completions');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
        verifyNever(mockAnalytics.track(any, props: anyNamed('props')));
      });
    });

    group('markMunrosAsCompleted', () {
      test('should mark munros as completed successfully', () async {
        // Arrange
        final munroIds = [10, 11, 12];
        final summitDateTime = DateTime(2024, 10, 5, 14, 30);
        final postId = 'post5';
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: munroIds,
          summitDateTime: summitDateTime,
          postId: postId,
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, 3);
        expect(munroCompletionState.completedMunroIds, {10, 11, 12});
        expect(munroCompletionState.munroCompletions.every((c) => c.postId == postId), true);
        expect(munroCompletionState.munroCompletions.every((c) => c.dateTimeCompleted == summitDateTime), true);
        verify(mockMunroCompletionsRepository.create(any)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should mark munros as completed without postId', () async {
        // Arrange
        final munroIds = [20, 21];
        final summitDateTime = DateTime(2024, 11, 10, 9, 15);
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: munroIds,
          summitDateTime: summitDateTime,
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, 2);
        expect(munroCompletionState.completedMunroIds, {20, 21});
        expect(munroCompletionState.munroCompletions.every((c) => c.postId == null), true);
      });

      test('should handle error when user is not logged in', () async {
        // Arrange
        reset(mockUserState);
        when(mockUserState.currentUser).thenReturn(null);
        final munroIds = [10];
        final summitDateTime = DateTime.now();

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: munroIds,
          summitDateTime: summitDateTime,
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'You must be logged in to mark munros as completed.');
        verifyNever(mockMunroCompletionsRepository.create(any));
      });

      test('should handle error during creation', () async {
        // Arrange
        final munroIds = [10];
        final summitDateTime = DateTime.now();
        when(mockMunroCompletionsRepository.create(any)).thenThrow(Exception('Creation failed'));

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: munroIds,
          summitDateTime: summitDateTime,
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'There was an issue marking your munros as completed');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should append to existing completions', () async {
        // Arrange - start with some existing completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => [sampleMunroCompletions.first]);
        await munroCompletionState.loadUserMunroCompletions();

        final munroIds = [25];
        final summitDateTime = DateTime(2024, 12, 1, 12, 0);
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: munroIds,
          summitDateTime: summitDateTime,
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, 2);
        expect(munroCompletionState.completedMunroIds, {1, 25});
      });
    });

    group('removeMunroCompletion', () {
      test('should remove munro completion successfully', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.delete(
          munroCompletionId: anyNamed('munroCompletionId'),
        )).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.removeMunroCompletion(
          munroCompletion: sampleMunroCompletions.first,
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, 2);
        expect(munroCompletionState.completedMunroIds, {2, 3});
        expect(
          munroCompletionState.munroCompletions.every((c) => c.id != 'completion1'),
          true,
        );
        verify(mockMunroCompletionsRepository.delete(
          munroCompletionId: 'completion1',
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error when user is not logged in', () async {
        // Arrange
        reset(mockUserState);
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await munroCompletionState.removeMunroCompletion(
          munroCompletion: sampleMunroCompletions.first,
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'You must be logged in to remove munro completions.');
        verifyNever(mockMunroCompletionsRepository.delete(munroCompletionId: anyNamed('munroCompletionId')));
      });

      test('should handle error during deletion', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.delete(
          munroCompletionId: anyNamed('munroCompletionId'),
        )).thenThrow(Exception('Deletion failed'));

        final initialCount = munroCompletionState.munroCompletions.length;

        // Act
        await munroCompletionState.removeMunroCompletion(
          munroCompletion: sampleMunroCompletions.first,
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'There was an issue removing your munro completion');
        // Original completions should remain unchanged
        expect(munroCompletionState.munroCompletions.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('removeCompletionsByMunroIdsAndPost', () {
      test('should remove completions by munro IDs and post ID successfully', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        )).thenAnswer((_) async => {});

        // Act - remove completions for munro IDs 1 and 2 with post1
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [1, 2],
          postId: 'post1',
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, 1);
        expect(munroCompletionState.completedMunroIds, {3});
        expect(munroCompletionState.munroCompletions.first.munroId, 3);
        verify(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: [1, 2],
          postId: 'post1',
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should only remove completions matching both munro ID and post ID', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        )).thenAnswer((_) async => {});

        // Act - try to remove completion for munro ID 3 with post1 (shouldn't match as munro 3 has no postId)
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [3],
          postId: 'post1',
        );

        // Assert - munro 3 should remain as it doesn't match the post ID
        expect(munroCompletionState.munroCompletions.length, 3);
        expect(munroCompletionState.completedMunroIds, {1, 2, 3});
      });

      test('should handle error when user is not logged in', () async {
        // Arrange
        reset(mockUserState);
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [1],
          postId: 'post1',
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'You must be logged in to remove munro completions.');
        verifyNever(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        ));
      });

      test('should handle error during deletion', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        )).thenThrow(Exception('Batch deletion failed'));

        final initialCount = munroCompletionState.munroCompletions.length;

        // Act
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [1, 2],
          postId: 'post1',
        );

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error.message, 'There was an issue removing your munro completions');
        // Original completions should remain unchanged
        expect(munroCompletionState.munroCompletions.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('setError', () {
      test('should set error and status', () {
        // Arrange
        final error = Error(code: 'test_code', message: 'test error message');

        // Act
        munroCompletionState.setError(error);

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.error);
        expect(munroCompletionState.error, error);
        expect(munroCompletionState.error.code, 'test_code');
        expect(munroCompletionState.error.message, 'test error message');
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () async {
        // Arrange - set up some state
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        // Act
        munroCompletionState.reset();

        // Assert
        expect(munroCompletionState.status, MunroCompletionsStatus.initial);
        expect(munroCompletionState.error, isA<Error>());
        expect(munroCompletionState.munroCompletions, isEmpty);
        expect(munroCompletionState.completedMunroIds, isEmpty);
      });
    });

    group('completedMunroIds', () {
      test('should return set of completed munro IDs', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.completedMunroIds, isA<Set<int>>());
        expect(munroCompletionState.completedMunroIds, {1, 2, 3});
      });

      test('should handle duplicate munro IDs in completions', () async {
        // Arrange - create completions with duplicate munro IDs
        final duplicateCompletions = [
          MunroCompletion(
            id: 'completion1',
            userId: 'testUserId',
            munroId: 1,
            postId: 'post1',
            dateTimeCompleted: DateTime(2024, 6, 15, 10, 30),
          ),
          MunroCompletion(
            id: 'completion2',
            userId: 'testUserId',
            munroId: 1,
            postId: 'post2',
            dateTimeCompleted: DateTime(2024, 7, 20, 14, 0),
          ),
        ];
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => duplicateCompletions);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(munroCompletionState.completedMunroIds, {1});
        expect(munroCompletionState.munroCompletions.length, 2);
      });
    });

    group('Edge Cases', () {
      test('should handle user with null uid', () async {
        // Arrange
        reset(mockUserState);
        final userWithNullUid = AppUser(
          uid: null,
          displayName: 'Test User',
        );
        when(mockUserState.currentUser).thenReturn(userWithNullUid);
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => []);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        verify(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: '',
        )).called(1);
      });

      test('should handle completion with null id during removal', () async {
        // Arrange
        final completionWithNullId = MunroCompletion(
          id: null,
          userId: 'testUserId',
          munroId: 50,
          postId: 'post10',
          dateTimeCompleted: DateTime.now(),
        );
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => [completionWithNullId]);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.delete(
          munroCompletionId: anyNamed('munroCompletionId'),
        )).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.removeMunroCompletion(
          munroCompletion: completionWithNullId,
        );

        // Assert
        verify(mockMunroCompletionsRepository.delete(
          munroCompletionId: '',
        )).called(1);
      });

      test('should handle empty munro IDs list when marking as completed', () async {
        // Arrange
        final emptyMunroIds = <int>[];
        final summitDateTime = DateTime.now();
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: emptyMunroIds,
          summitDateTime: summitDateTime,
        );

        // Assert
        expect(munroCompletionState.munroCompletions, isEmpty);
        verify(mockMunroCompletionsRepository.create([])).called(1);
      });

      test('should handle empty munro IDs list when removing by IDs and post', () async {
        // Arrange - start with some completions
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        )).thenAnswer((_) async => {});

        final initialCount = munroCompletionState.munroCompletions.length;

        // Act
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [],
          postId: 'post1',
        );

        // Assert
        expect(munroCompletionState.munroCompletions.length, initialCount);
        verify(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: [],
          postId: 'post1',
        )).called(1);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading completions', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when adding bulk completions', () async {
        // Arrange
        final newCompletions = [
          MunroCompletion(
            userId: 'testUserId',
            munroId: 4,
            postId: 'post2',
            dateTimeCompleted: DateTime.now(),
          ),
        ];
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.addBulkCompletions(munroCompletions: newCompletions);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when marking munros as completed', () async {
        // Arrange
        when(mockMunroCompletionsRepository.create(any)).thenAnswer((_) async => {});

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.markMunrosAsCompleted(
          munroIds: [1],
          summitDateTime: DateTime.now(),
        );

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when removing completion', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.delete(
          munroCompletionId: anyNamed('munroCompletionId'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.removeMunroCompletion(
          munroCompletion: sampleMunroCompletions.first,
        );

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when removing by IDs and post', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => sampleMunroCompletions);
        await munroCompletionState.loadUserMunroCompletions();

        when(mockMunroCompletionsRepository.deleteByMunroIdsAndPostId(
          munroIds: anyNamed('munroIds'),
          postId: anyNamed('postId'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.removeCompletionsByMunroIdsAndPost(
          munroIds: [1, 2],
          postId: 'post1',
        );

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting error', () {
        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        munroCompletionState.setError(Error(message: 'test error'));

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        // Arrange - set up some state
        munroCompletionState.setError(Error(message: 'test error'));

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        munroCompletionState.reset();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners on error during load', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Error'));

        bool notified = false;
        munroCompletionState.addListener(() => notified = true);

        // Act
        await munroCompletionState.loadUserMunroCompletions();

        // Assert
        expect(notified, true);
      });
    });
  });
}
