import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/photo_gallery/state/photo_gallery_state.dart';

import 'photo_gallery_state_test.mocks.dart';

// Mock Photo class for testing
class MockPhoto {
  final String id;
  final String url;
  final String authorId;

  MockPhoto({
    required this.id,
    required this.url,
    required this.authorId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockPhoto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          url == other.url &&
          authorId == other.authorId;

  @override
  int get hashCode => id.hashCode ^ url.hashCode ^ authorId.hashCode;
}

// Generate mocks
@GenerateMocks([
  UserState,
  Logger,
])
void main() {
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late PhotoGalleryState<MockPhoto> photoGalleryState;
  late PageLoader<MockPhoto> mockPageLoader;

  late List<MockPhoto> samplePhotos;
  late List<MockPhoto> additionalPhotos;

  setUp(() {
    // Sample photo data for testing
    samplePhotos = [
      MockPhoto(
        id: 'photo1',
        url: 'https://example.com/photo1.jpg',
        authorId: 'user1',
      ),
      MockPhoto(
        id: 'photo2',
        url: 'https://example.com/photo2.jpg',
        authorId: 'user2',
      ),
      MockPhoto(
        id: 'photo3',
        url: 'https://example.com/photo3.jpg',
        authorId: 'user3',
      ),
    ];

    additionalPhotos = [
      MockPhoto(
        id: 'photo4',
        url: 'https://example.com/photo4.jpg',
        authorId: 'user4',
      ),
      MockPhoto(
        id: 'photo5',
        url: 'https://example.com/photo5.jpg',
        authorId: 'user5',
      ),
    ];

    mockUserState = MockUserState();
    mockLogger = MockLogger();

    // Create a mock page loader function
    mockPageLoader = ({
      required int offset,
      required int count,
      required List<String> excludedAuthorIds,
    }) async {
      return samplePhotos;
    };

    photoGalleryState = PhotoGalleryState<MockPhoto>(
      mockUserState,
      mockLogger,
      mockPageLoader,
    );

    // Default mock behavior for UserState
    when(mockUserState.blockedUsers).thenReturn([]);
  });

  group('PhotoGalleryState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(photoGalleryState.status, PhotoGalleryStatus.initial);
        expect(photoGalleryState.error, isA<Error>());
        expect(photoGalleryState.photos, isEmpty);
      });
    });

    group('loadInitital', () {
      test('should load photos successfully', () async {
        // Arrange
        int loadCallCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            loadCallCount++;
            expect(offset, 0);
            expect(count, 20);
            expect(excludedAuthorIds, []);
            return samplePhotos;
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos, samplePhotos);
        expect(photoGalleryState.photos.length, 3);
        expect(loadCallCount, 1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        List<String>? capturedExcludedUsers;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            capturedExcludedUsers = excludedAuthorIds;
            return samplePhotos;
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(capturedExcludedUsers, blockedUsers);
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
      });

      test('should handle error during loading', () async {
        // Arrange
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            throw Exception('Network error');
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.error);
        expect(photoGalleryState.error.message, 'There was an issue loading pictures. Please try again.');
        expect(photoGalleryState.photos, isEmpty);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            // Simulate async delay
            await Future.delayed(Duration.zero);
            return samplePhotos;
          },
        );

        // Act
        final future = photoGalleryState.loadInitital();

        // Assert intermediate state
        expect(photoGalleryState.status, PhotoGalleryStatus.loading);

        // Wait for completion
        await future;
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
      });

      test('should load empty list successfully', () async {
        // Arrange
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return [];
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos, isEmpty);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should request correct count and offset parameters', () async {
        // Arrange
        int? capturedOffset;
        int? capturedCount;

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            capturedOffset = offset;
            capturedCount = count;
            return samplePhotos;
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(capturedOffset, 0);
        expect(capturedCount, 20);
      });
    });

    group('paginate', () {
      test('should paginate photos successfully', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 1) {
              // Initial load
              return samplePhotos;
            } else {
              // Pagination
              expect(offset, 3);
              expect(count, 20);
              return additionalPhotos;
            }
          },
        );

        // Load initial photos
        await photoGalleryState.loadInitital();

        // Act
        final result = await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos.length, 5);
        expect(photoGalleryState.photos[3].id, 'photo4');
        expect(photoGalleryState.photos[4].id, 'photo5');
        expect(result, additionalPhotos);
        expect(callCount, 2);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        List<String>? capturedExcludedUsers;
        int callCount = 0;

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 2) {
              // Capture on pagination call
              capturedExcludedUsers = excludedAuthorIds;
            }
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        // Act
        await photoGalleryState.paginate();

        // Assert
        expect(capturedExcludedUsers, blockedUsers);
      });

      test('should handle error during pagination', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 1) {
              return samplePhotos;
            } else {
              throw Exception('Pagination error');
            }
          },
        );

        await photoGalleryState.loadInitital();
        final initialCount = photoGalleryState.photos.length;

        // Act
        final result = await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.error);
        expect(photoGalleryState.error.message, 'There was an issue loading pictures Please try again.');
        // Original photos should remain unchanged
        expect(photoGalleryState.photos.length, initialCount);
        expect(result, isEmpty);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 2) {
              // Simulate async delay on pagination
              await Future.delayed(Duration.zero);
            }
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        // Act
        final future = photoGalleryState.paginate();

        // Assert intermediate state
        expect(photoGalleryState.status, PhotoGalleryStatus.paginating);

        // Wait for completion
        await future;
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
      });

      test('should paginate from empty list', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 1) {
              return [];
            } else {
              expect(offset, 0);
              return samplePhotos;
            }
          },
        );

        await photoGalleryState.loadInitital();
        expect(photoGalleryState.photos, isEmpty);

        // Act
        final result = await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.photos, samplePhotos);
        expect(result, samplePhotos);
      });

      test('should handle empty pagination result', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            return callCount == 1 ? samplePhotos : [];
          },
        );

        await photoGalleryState.loadInitital();
        final initialCount = photoGalleryState.photos.length;

        // Act
        final result = await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos.length, initialCount);
        expect(result, isEmpty);
      });

      test('should use correct offset based on current photos length', () async {
        // Arrange
        int? paginationOffset;
        int callCount = 0;

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 2) {
              paginationOffset = offset;
            }
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        // Act
        await photoGalleryState.paginate();

        // Assert
        expect(paginationOffset, 3);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        photoGalleryState.setStatus = PhotoGalleryStatus.loading;
        expect(photoGalleryState.status, PhotoGalleryStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        photoGalleryState.setError = error;

        expect(photoGalleryState.status, PhotoGalleryStatus.error);
        expect(photoGalleryState.error, error);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading photos', () async {
        // Arrange
        bool notified = false;
        photoGalleryState.addListener(() {
          notified = true;
        });

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return samplePhotos;
          },
        );

        photoGalleryState.addListener(() {
          notified = true;
        });

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        bool notified = false;
        photoGalleryState.addListener(() {
          notified = true;
        });

        // Act
        await photoGalleryState.paginate();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        // Arrange
        bool notified = false;
        photoGalleryState.addListener(() {
          notified = true;
        });

        // Act
        photoGalleryState.setStatus = PhotoGalleryStatus.loading;

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        // Arrange
        bool notified = false;
        photoGalleryState.addListener(() {
          notified = true;
        });

        // Act
        photoGalleryState.setError = Error(message: 'test error');

        // Assert
        expect(notified, true);
      });

      test('should notify listeners multiple times during load operation', () async {
        // Arrange
        int notificationCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return samplePhotos;
          },
        );

        photoGalleryState.addListener(() {
          notificationCount++;
        });

        // Act
        await photoGalleryState.loadInitital();

        // Assert - should notify at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });

      test('should notify listeners multiple times during pagination', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        int notificationCount = 0;
        photoGalleryState.addListener(() {
          notificationCount++;
        });

        // Act
        await photoGalleryState.paginate();

        // Assert - should notify at least twice (paginating and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('Edge Cases', () {
      test('should handle very large photo lists', () async {
        // Arrange
        final largePhotoList = List.generate(
          1000,
          (index) => MockPhoto(
            id: 'photo$index',
            url: 'https://example.com/photo$index.jpg',
            authorId: 'user$index',
          ),
        );

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return largePhotoList;
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos.length, 1000);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4', 'blocked5'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        List<String>? capturedExcludedUsers;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            capturedExcludedUsers = excludedAuthorIds;
            return samplePhotos;
          },
        );

        // Act
        await photoGalleryState.loadInitital();

        // Assert
        expect(capturedExcludedUsers, blockedUsers);
        expect(capturedExcludedUsers?.length, 5);
      });

      test('should handle consecutive pagination calls', () async {
        // Arrange
        int callCount = 0;
        final List<List<MockPhoto>> paginationResults = [
          samplePhotos,
          additionalPhotos,
          [
            MockPhoto(
              id: 'photo6',
              url: 'https://example.com/photo6.jpg',
              authorId: 'user6',
            )
          ],
        ];

        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            final result = paginationResults[callCount];
            callCount++;
            return result;
          },
        );

        await photoGalleryState.loadInitital();

        // Act
        await photoGalleryState.paginate();
        await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.photos.length, 6);
        expect(callCount, 3);
      });

      test('should maintain photo order across pagination', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            return callCount == 1 ? samplePhotos : additionalPhotos;
          },
        );

        await photoGalleryState.loadInitital();

        // Act
        await photoGalleryState.paginate();

        // Assert
        expect(photoGalleryState.photos[0].id, 'photo1');
        expect(photoGalleryState.photos[1].id, 'photo2');
        expect(photoGalleryState.photos[2].id, 'photo3');
        expect(photoGalleryState.photos[3].id, 'photo4');
        expect(photoGalleryState.photos[4].id, 'photo5');
      });

      test('should handle error then successful retry', () async {
        // Arrange
        int callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('First attempt failed');
            }
            return samplePhotos;
          },
        );

        // Act - First attempt fails
        await photoGalleryState.loadInitital();
        expect(photoGalleryState.status, PhotoGalleryStatus.error);

        // Create new instance for retry
        callCount = 0;
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('First attempt failed');
            }
            return samplePhotos;
          },
        );

        await photoGalleryState.loadInitital();
        expect(photoGalleryState.status, PhotoGalleryStatus.error);

        // Retry with working loader
        photoGalleryState = PhotoGalleryState<MockPhoto>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return samplePhotos;
          },
        );

        await photoGalleryState.loadInitital();

        // Assert - Second attempt succeeds
        expect(photoGalleryState.status, PhotoGalleryStatus.loaded);
        expect(photoGalleryState.photos, samplePhotos);
      });
    });

    group('Generic Type Support', () {
      test('should work with different photo types', () async {
        // Test with String type
        final stringGalleryState = PhotoGalleryState<String>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return ['url1', 'url2', 'url3'];
          },
        );

        await stringGalleryState.loadInitital();

        expect(stringGalleryState.photos, ['url1', 'url2', 'url3']);
        expect(stringGalleryState.status, PhotoGalleryStatus.loaded);
      });

      test('should work with map types', () async {
        // Test with Map type
        final mapGalleryState = PhotoGalleryState<Map<String, dynamic>>(
          mockUserState,
          mockLogger,
          ({
            required int offset,
            required int count,
            required List<String> excludedAuthorIds,
          }) async {
            return [
              {'id': '1', 'url': 'url1'},
              {'id': '2', 'url': 'url2'},
            ];
          },
        );

        await mapGalleryState.loadInitital();

        expect(mapGalleryState.photos.length, 2);
        expect(mapGalleryState.photos[0]['id'], '1');
        expect(mapGalleryState.status, PhotoGalleryStatus.loaded);
      });
    });
  });
}
