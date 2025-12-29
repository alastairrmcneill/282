import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

void main() {
  late BulkMunroUpdateState bulkMunroUpdateState;

  late List<MunroCompletion> sampleMunroCompletions;
  late List<MunroCompletion> additionalMunroCompletions;

  setUp(() {
    // Sample munro completion data for testing
    sampleMunroCompletions = [
      MunroCompletion(
        id: 'completion1',
        userId: 'user1',
        munroId: 101,
        dateTimeCompleted: DateTime(2024, 1, 15),
        postId: 'post1',
      ),
      MunroCompletion(
        id: 'completion2',
        userId: 'user1',
        munroId: 102,
        dateTimeCompleted: DateTime(2024, 2, 20),
        postId: 'post2',
      ),
      MunroCompletion(
        id: 'completion3',
        userId: 'user1',
        munroId: 103,
        dateTimeCompleted: DateTime(2024, 3, 10),
        postId: null,
      ),
    ];

    additionalMunroCompletions = [
      MunroCompletion(
        userId: 'user1',
        munroId: 104,
        dateTimeCompleted: DateTime(2024, 4, 5),
        postId: null,
      ),
      MunroCompletion(
        userId: 'user1',
        munroId: 105,
        dateTimeCompleted: DateTime(2024, 5, 12),
        postId: 'post3',
      ),
    ];

    bulkMunroUpdateState = BulkMunroUpdateState();

    // Reset the state to ensure clean slate for each test
    bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.initial;
    bulkMunroUpdateState.setStartingBulkMunroUpdateList = [];
  });

  group('BulkMunroUpdateState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.initial);
        expect(bulkMunroUpdateState.error, isA<Error>());
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList, isEmpty);
        expect(bulkMunroUpdateState.bulkMunroUpdateList, isEmpty);
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loading;
        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        bulkMunroUpdateState.setError = error;

        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.error);
        expect(bulkMunroUpdateState.error, error);
      });

      test('setStartingBulkMunroUpdateList should update starting list', () {
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        expect(bulkMunroUpdateState.startingBulkMunroUpdateList, sampleMunroCompletions);
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, 3);
      });

      test('setStartingBulkMunroUpdateList should clear added completions', () {
        // Arrange - add some completions first
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);

        // Act - set new starting list
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        // Assert - added completions should be cleared
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList, sampleMunroCompletions);
      });
    });

    group('bulkMunroUpdateList getter', () {
      test('should return combined list of starting and added completions', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        // Act
        final combinedList = bulkMunroUpdateState.bulkMunroUpdateList;

        // Assert
        expect(combinedList.length, 5);
        expect(combinedList.take(3).toList(), sampleMunroCompletions);
        expect(combinedList.skip(3).toList(), additionalMunroCompletions);
      });

      test('should return only starting list when no added completions', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        // Act
        final combinedList = bulkMunroUpdateState.bulkMunroUpdateList;

        // Assert
        expect(combinedList.length, 3);
        expect(combinedList, sampleMunroCompletions);
      });

      test('should return only added completions when starting list is empty', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        // Act
        final combinedList = bulkMunroUpdateState.bulkMunroUpdateList;

        // Assert
        expect(combinedList.length, 2);
        expect(combinedList, additionalMunroCompletions);
      });

      test('should return empty list when both lists are empty', () {
        // Act
        final combinedList = bulkMunroUpdateState.bulkMunroUpdateList;

        // Assert
        expect(combinedList, isEmpty);
      });
    });

    group('addMunroCompleted', () {
      test('should add munro completion to added list', () {
        // Arrange
        final completion = additionalMunroCompletions[0];

        // Act
        bulkMunroUpdateState.addMunroCompleted(completion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first, completion);
      });

      test('should add multiple munro completions', () {
        // Act
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);
        expect(bulkMunroUpdateState.addedMunroCompletions[0], additionalMunroCompletions[0]);
        expect(bulkMunroUpdateState.addedMunroCompletions[1], additionalMunroCompletions[1]);
      });

      test('should add completion without affecting starting list', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        final initialStartingLength = bulkMunroUpdateState.startingBulkMunroUpdateList.length;

        // Act
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        // Assert
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, initialStartingLength);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
      });

      test('should handle adding completion with null id', () {
        // Arrange
        final completion = MunroCompletion(
          userId: 'user1',
          munroId: 999,
          dateTimeCompleted: DateTime(2024, 12, 25),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.addMunroCompleted(completion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.id, isNull);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.munroId, 999);
      });

      test('should handle adding completion with null postId', () {
        // Arrange
        final completion = MunroCompletion(
          id: 'completion999',
          userId: 'user1',
          munroId: 999,
          dateTimeCompleted: DateTime(2024, 12, 25),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.addMunroCompleted(completion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.postId, isNull);
      });
    });

    group('updateMunroCompleted', () {
      test('should update existing munro completion', () {
        // Arrange
        final originalCompletion = MunroCompletion(
          id: 'completion1',
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 5),
          postId: null,
        );
        bulkMunroUpdateState.addMunroCompleted(originalCompletion);

        final updatedCompletion = MunroCompletion(
          id: 'completion1',
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 10),
          postId: 'post4',
        );

        // Act
        bulkMunroUpdateState.updateMunroCompleted(updatedCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.dateTimeCompleted, DateTime(2024, 4, 10));
        expect(bulkMunroUpdateState.addedMunroCompletions.first.postId, 'post4');
      });

      test('should remove old completion and add updated one', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);

        final updatedCompletion = MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 15),
          postId: 'updated_post',
        );

        // Act
        bulkMunroUpdateState.updateMunroCompleted(updatedCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);
        final updated = bulkMunroUpdateState.addedMunroCompletions.firstWhere(
          (c) => c.munroId == 104,
        );
        expect(updated.dateTimeCompleted, DateTime(2024, 4, 15));
        expect(updated.postId, 'updated_post');
      });

      test('should add completion if munroId does not exist', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);

        final newCompletion = MunroCompletion(
          userId: 'user1',
          munroId: 999,
          dateTimeCompleted: DateTime(2024, 12, 1),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.updateMunroCompleted(newCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);
        expect(bulkMunroUpdateState.addedMunroCompletions.any((c) => c.munroId == 999), true);
      });

      test('should maintain other completions when updating', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        final updatedCompletion = MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 20),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.updateMunroCompleted(updatedCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);
        expect(bulkMunroUpdateState.addedMunroCompletions.any((c) => c.munroId == 105), true);
      });
    });

    group('removeMunroCompletion', () {
      test('should remove munro completion by id', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 2);

        // Act
        bulkMunroUpdateState.removeMunroCompletion(104);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.munroId, 105);
      });

      test('should handle removing non-existent munro id', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);

        // Act
        bulkMunroUpdateState.removeMunroCompletion(999);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.munroId, 104);
      });

      test('should handle removing from empty list', () {
        // Arrange
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);

        // Act
        bulkMunroUpdateState.removeMunroCompletion(104);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
      });

      test('should remove all completions with matching munro id', () {
        // Arrange - add same munro twice (edge case, but should handle it)
        final completion1 = MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 5),
          postId: null,
        );
        final completion2 = MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 10),
          postId: 'post4',
        );
        bulkMunroUpdateState.addMunroCompleted(completion1);
        bulkMunroUpdateState.addMunroCompleted(completion2);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 3);

        // Act
        bulkMunroUpdateState.removeMunroCompletion(104);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.munroId, 105);
      });

      test('should not affect starting list when removing', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        final startingLength = bulkMunroUpdateState.startingBulkMunroUpdateList.length;

        // Act
        bulkMunroUpdateState.removeMunroCompletion(104);

        // Assert
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, startingLength);
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle adding completion with past date', () {
        // Arrange
        final pastCompletion = MunroCompletion(
          userId: 'user1',
          munroId: 201,
          dateTimeCompleted: DateTime(2020, 1, 1),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.addMunroCompleted(pastCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.dateTimeCompleted, DateTime(2020, 1, 1));
      });

      test('should handle adding completion with future date', () {
        // Arrange
        final futureCompletion = MunroCompletion(
          userId: 'user1',
          munroId: 202,
          dateTimeCompleted: DateTime(2030, 12, 31),
          postId: null,
        );

        // Act
        bulkMunroUpdateState.addMunroCompleted(futureCompletion);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.dateTimeCompleted, DateTime(2030, 12, 31));
      });

      test('should handle large number of completions', () {
        // Arrange
        final largeList = List.generate(
          100,
          (index) => MunroCompletion(
            userId: 'user1',
            munroId: 1000 + index,
            dateTimeCompleted: DateTime(2024, 1, 1).add(Duration(days: index)),
            postId: null,
          ),
        );

        // Act
        for (var completion in largeList) {
          bulkMunroUpdateState.addMunroCompleted(completion);
        }

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 100);
        expect(bulkMunroUpdateState.bulkMunroUpdateList.length, 100);
      });

      test('should handle updating with same munroId multiple times', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        // Act - update multiple times
        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 10),
          postId: 'update1',
        ));
        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 15),
          postId: 'update2',
        ));
        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 20),
          postId: 'update3',
        ));

        // Assert - should only have one completion with latest update
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.postId, 'update3');
        expect(bulkMunroUpdateState.addedMunroCompletions.first.dateTimeCompleted, DateTime(2024, 4, 20));
      });

      test('should handle mixed operations correctly', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        // Act - perform various operations
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        bulkMunroUpdateState.removeMunroCompletion(104);
        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
          userId: 'user1',
          munroId: 105,
          dateTimeCompleted: DateTime(2024, 5, 20),
          postId: 'updated',
        ));

        // Assert
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, 3);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.munroId, 105);
        expect(bulkMunroUpdateState.addedMunroCompletions.first.postId, 'updated');
        expect(bulkMunroUpdateState.bulkMunroUpdateList.length, 4);
      });

      test('should handle setting starting list to empty', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, 3);

        // Act
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = [];

        // Assert
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList, isEmpty);
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when status changes', () {
        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when setting starting list', () {
        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        expect(notified, true);
      });

      test('should notify listeners when adding munro completion', () {
        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        expect(notified, true);
      });

      test('should notify listeners when updating munro completion', () {
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.updateMunroCompleted(MunroCompletion(
          userId: 'user1',
          munroId: 104,
          dateTimeCompleted: DateTime(2024, 4, 15),
          postId: 'updated',
        ));

        expect(notified, true);
      });

      test('should notify listeners when removing munro completion', () {
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        bool notified = false;
        bulkMunroUpdateState.addListener(() => notified = true);

        bulkMunroUpdateState.removeMunroCompletion(104);

        expect(notified, true);
      });

      test('should notify listeners multiple times for multiple changes', () {
        int notifyCount = 0;
        bulkMunroUpdateState.addListener(() => notifyCount++);

        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);
        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loaded;

        expect(notifyCount, 3);
      });

      test('should notify listeners when clearing via setStartingBulkMunroUpdateList', () {
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        int notifyCount = 0;
        bulkMunroUpdateState.addListener(() => notifyCount++);

        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;

        expect(notifyCount, 1);
        expect(bulkMunroUpdateState.addedMunroCompletions, isEmpty);
      });
    });

    group('Status Management', () {
      test('should transition through status states correctly', () {
        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.initial);

        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loading;
        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.loading);

        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loaded;
        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.loaded);
      });

      test('should set status to error when error is set', () {
        bulkMunroUpdateState.setStatus = BulkMunroUpdateStatus.loaded;

        bulkMunroUpdateState.setError = Error(message: 'test error');

        expect(bulkMunroUpdateState.status, BulkMunroUpdateStatus.error);
      });

      test('should preserve error message when error is set', () {
        final error = Error(code: '404', message: 'Not found');

        bulkMunroUpdateState.setError = error;

        expect(bulkMunroUpdateState.error.code, '404');
        expect(bulkMunroUpdateState.error.message, 'Not found');
      });
    });

    group('Data Integrity', () {
      test('should maintain separate starting and added lists', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        // Act & Assert
        expect(bulkMunroUpdateState.startingBulkMunroUpdateList.length, 3);
        expect(bulkMunroUpdateState.addedMunroCompletions.length, 1);
        expect(bulkMunroUpdateState.bulkMunroUpdateList.length, 4);
      });

      test('should not mutate original list when setting starting list', () {
        // Arrange
        final originalList = List<MunroCompletion>.from(sampleMunroCompletions);

        // Act
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);

        // Assert
        expect(originalList.length, sampleMunroCompletions.length);
      });

      test('should handle removal that does not exist gracefully', () {
        // Arrange
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        final initialLength = bulkMunroUpdateState.addedMunroCompletions.length;

        // Act
        bulkMunroUpdateState.removeMunroCompletion(999);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions.length, initialLength);
      });

      test('should preserve order of added completions', () {
        // Act
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        // Assert
        expect(bulkMunroUpdateState.addedMunroCompletions[0].munroId, 104);
        expect(bulkMunroUpdateState.addedMunroCompletions[1].munroId, 105);
      });

      test('should preserve order in bulkMunroUpdateList', () {
        // Arrange
        bulkMunroUpdateState.setStartingBulkMunroUpdateList = sampleMunroCompletions;
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[0]);
        bulkMunroUpdateState.addMunroCompleted(additionalMunroCompletions[1]);

        // Act
        final combinedList = bulkMunroUpdateState.bulkMunroUpdateList;

        // Assert
        expect(combinedList[0].munroId, 101);
        expect(combinedList[1].munroId, 102);
        expect(combinedList[2].munroId, 103);
        expect(combinedList[3].munroId, 104);
        expect(combinedList[4].munroId, 105);
      });
    });
  });
}
