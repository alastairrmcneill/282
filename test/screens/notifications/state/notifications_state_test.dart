import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'notifications_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  NotificationsRepository,
  UserState,
  Logger,
])
void main() {
  late MockNotificationsRepository mockNotificationsRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late NotificationsState notificationsState;

  late List<Notif> sampleNotifications;
  late AppUser currentUser;

  setUp(() {
    // Sample current user
    currentUser = AppUser(
      uid: 'currentUser',
      displayName: 'Current User',
      searchName: 'current user',
      profilePictureURL: 'https://example.com/current.jpg',
      dateCreated: DateTime(2024, 1, 1),
    );

    // Sample notification data for testing
    sampleNotifications = [
      Notif(
        uid: 'notif1',
        postId: 'post1',
        targetId: 'currentUser',
        sourceId: 'user1',
        sourceDisplayName: 'User One',
        sourceProfilePictureURL: 'https://example.com/user1.jpg',
        type: 'like',
        dateTime: DateTime(2024, 12, 15),
        read: false,
      ),
      Notif(
        uid: 'notif2',
        postId: 'post2',
        targetId: 'currentUser',
        sourceId: 'user2',
        sourceDisplayName: 'User Two',
        sourceProfilePictureURL: 'https://example.com/user2.jpg',
        type: 'comment',
        dateTime: DateTime(2024, 12, 14),
        read: false,
      ),
      Notif(
        uid: 'notif3',
        postId: null,
        targetId: 'currentUser',
        sourceId: 'user3',
        sourceDisplayName: 'User Three',
        sourceProfilePictureURL: null,
        type: 'follow',
        dateTime: DateTime(2024, 12, 13),
        read: true,
      ),
    ];

    mockNotificationsRepository = MockNotificationsRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    notificationsState = NotificationsState(
      mockNotificationsRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(currentUser);
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    notificationsState.reset();
  });

  group('NotificationsState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(notificationsState.status, NotificationsStatus.initial);
        expect(notificationsState.error, isA<Error>());
        expect(notificationsState.notifications, isEmpty);
      });
    });

    group('getUserNotifications', () {
      test('should load notifications successfully', () async {
        // Arrange
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => sampleNotifications);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        expect(notificationsState.status, NotificationsStatus.loaded);
        expect(notificationsState.notifications, sampleNotifications);
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: [],
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => sampleNotifications);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: blockedUsers,
        )).called(1);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenThrow(Exception('Network error'));

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        expect(notificationsState.status, NotificationsStatus.error);
        expect(notificationsState.error.message, 'There was an issue retreiving your notifications. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleNotifications;
        });

        // Act
        final future = notificationsState.getUserNotifications();

        // Assert intermediate state
        expect(notificationsState.status, NotificationsStatus.loading);

        // Wait for completion
        await future;
        expect(notificationsState.status, NotificationsStatus.loaded);
      });

      test('should handle empty currentUser uid', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => []);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        verify(mockNotificationsRepository.readUserNotifs(
          userId: '',
          excludedSourceIds: [],
        )).called(1);
      });
    });

    group('paginateUserNotifications', () {
      test('should paginate notifications successfully', () async {
        // Set initial notifications - use a copy to avoid mutating sampleNotifications
        notificationsState.setNotifications = List.from(sampleNotifications);
        // Arrange
        final additionalNotifications = [
          Notif(
            uid: 'notif4',
            postId: 'post4',
            targetId: 'currentUser',
            sourceId: 'user4',
            sourceDisplayName: 'User Four',
            sourceProfilePictureURL: 'https://example.com/user4.jpg',
            type: 'like',
            dateTime: DateTime(2024, 12, 12),
            read: false,
          ),
        ];

        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalNotifications);

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        expect(notificationsState.status, NotificationsStatus.loaded);
        expect(notificationsState.notifications.length, 4);
        expect(notificationsState.notifications.last.sourceDisplayName, 'User Four');
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial notification count
        final initialCount = notificationsState.notifications.length;

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        expect(notificationsState.status, NotificationsStatus.error);
        expect(notificationsState.error.message, 'There was an issue retreiving your notifications. Please try again.');
        // Original notifications should remain unchanged
        expect(notificationsState.notifications.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = notificationsState.paginateUserNotifications();

        // Assert intermediate state
        expect(notificationsState.status, NotificationsStatus.paginating);

        // Wait for completion
        await future;
        expect(notificationsState.status, NotificationsStatus.loaded);
      });

      test('should handle empty currentUser uid', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        verify(mockNotificationsRepository.readUserNotifs(
          userId: '',
          excludedSourceIds: [],
          offset: 0,
        )).called(1);
      });
    });

    group('markNotificationAsRead', () {
      test('should mark notification as read successfully', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final notificationToMark = sampleNotifications[0];
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markNotificationAsRead(notificationToMark);

        // Assert
        expect(notificationsState.notifications[0].read, true);
        verify(mockNotificationsRepository.updateNotif(
          notification: argThat(
            predicate<Notif>((n) => n.uid == 'notif1' && n.read == true),
            named: 'notification',
          ),
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should update notification in list', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final notificationToMark = sampleNotifications[1];
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Verify initial state
        expect(notificationsState.notifications[1].read, false);

        // Act
        await notificationsState.markNotificationAsRead(notificationToMark);

        // Assert
        expect(notificationsState.notifications[1].read, true);
        expect(notificationsState.notifications[1].uid, 'notif2');
      });

      test('should handle notification not found in list', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final nonExistentNotification = Notif(
          uid: 'notifNonExistent',
          postId: 'post999',
          targetId: 'currentUser',
          sourceId: 'userX',
          sourceDisplayName: 'User X',
          sourceProfilePictureURL: null,
          type: 'like',
          dateTime: DateTime(2024, 12, 10),
          read: false,
        );
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markNotificationAsRead(nonExistentNotification);

        // Assert - should not crash and repository should still be called
        verify(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).called(1);
        // List should remain unchanged
        expect(notificationsState.notifications.length, 3);
      });

      test('should handle error during mark as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final notificationToMark = sampleNotifications[0];
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenThrow(Exception('Update error'));

        // Store initial read status
        final initialReadStatus = notificationsState.notifications[0].read;

        // Act
        await notificationsState.markNotificationAsRead(notificationToMark);

        // Assert
        expect(notificationsState.status, NotificationsStatus.error);
        expect(notificationsState.error.message,
            'There was an issue marking your notification as done. Please try again.');
        // Notification should not be updated in list on error
        expect(notificationsState.notifications[0].read, initialReadStatus);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should preserve notification properties when marking as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        final notificationToMark = sampleNotifications[0];
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markNotificationAsRead(notificationToMark);

        // Assert
        final updatedNotif = notificationsState.notifications[0];
        expect(updatedNotif.uid, notificationToMark.uid);
        expect(updatedNotif.postId, notificationToMark.postId);
        expect(updatedNotif.sourceId, notificationToMark.sourceId);
        expect(updatedNotif.sourceDisplayName, notificationToMark.sourceDisplayName);
        expect(updatedNotif.type, notificationToMark.type);
        expect(updatedNotif.read, true);
      });
    });

    group('markAllNotificationsAsRead', () {
      test('should mark all unread notifications as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Verify initial state - 2 unread, 1 read
        expect(notificationsState.notifications.where((n) => !n.read).length, 2);
        expect(notificationsState.notifications.where((n) => n.read).length, 1);

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        expect(notificationsState.notifications.every((n) => n.read), true);
        // Should be called for each unread notification
        verify(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).called(2);
      });

      test('should update all notifications in list', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        for (var notification in notificationsState.notifications) {
          expect(notification.read, true);
        }
      });

      test('should handle error during mark all as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenThrow(Exception('Update error'));

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        expect(notificationsState.status, NotificationsStatus.error);
        expect(notificationsState.error.message,
            'There was an issue marking your notifications as done. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle empty notifications list', () async {
        // Arrange
        notificationsState.setNotifications = [];
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        verifyNever(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        ));
      });

      test('should not call repository for already read notifications', () async {
        // Arrange
        final allReadNotifications = sampleNotifications.map((n) => n.copyWith(read: true)).toList();
        notificationsState.setNotifications = List.from(allReadNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        verifyNever(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        ));
      });

      test('should preserve notification properties when marking all as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Store original properties
        final originalUids = sampleNotifications.map((n) => n.uid).toList();
        final originalTypes = sampleNotifications.map((n) => n.type).toList();

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        for (int i = 0; i < notificationsState.notifications.length; i++) {
          expect(notificationsState.notifications[i].uid, originalUids[i]);
          expect(notificationsState.notifications[i].type, originalTypes[i]);
        }
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        notificationsState.setStatus = NotificationsStatus.loading;
        expect(notificationsState.status, NotificationsStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        notificationsState.setError = error;

        expect(notificationsState.status, NotificationsStatus.error);
        expect(notificationsState.error, error);
      });

      test('setNotifications should update notifications list', () {
        notificationsState.setNotifications = sampleNotifications;

        expect(notificationsState.notifications, sampleNotifications);
        expect(notificationsState.notifications.length, 3);
      });

      test('addNotifications should append to existing notifications', () {
        notificationsState.setNotifications = [sampleNotifications.first];

        notificationsState.addNotifications = [sampleNotifications[1], sampleNotifications[2]];

        expect(notificationsState.notifications.length, 3);
        expect(notificationsState.notifications[0], sampleNotifications[0]);
        expect(notificationsState.notifications[1], sampleNotifications[1]);
        expect(notificationsState.notifications[2], sampleNotifications[2]);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        notificationsState.setNotifications = sampleNotifications;
        notificationsState.setStatus = NotificationsStatus.loaded;

        // Act
        notificationsState.reset();

        // Assert
        expect(notificationsState.status, NotificationsStatus.initial);
        expect(notificationsState.error, isA<Error>());
        expect(notificationsState.notifications, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty notifications list on pagination', () async {
        // Arrange - start with empty list
        expect(notificationsState.notifications, isEmpty);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleNotifications);

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        expect(notificationsState.notifications, sampleNotifications);
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final notificationWithNullURL = Notif(
          uid: 'notif5',
          postId: 'post5',
          targetId: 'currentUser',
          sourceId: 'user5',
          sourceDisplayName: 'User Five',
          sourceProfilePictureURL: null,
          type: 'follow',
          dateTime: DateTime(2024, 12, 11),
          read: false,
        );

        // Act
        notificationsState.setNotifications = [notificationWithNullURL];

        // Assert
        expect(notificationsState.notifications.first.sourceProfilePictureURL, isNull);
      });

      test('should handle null post IDs', () {
        // Arrange
        final notificationWithNullPostId = Notif(
          uid: 'notif6',
          postId: null,
          targetId: 'currentUser',
          sourceId: 'user6',
          sourceDisplayName: 'User Six',
          sourceProfilePictureURL: 'https://example.com/user6.jpg',
          type: 'follow',
          dateTime: DateTime(2024, 12, 10),
          read: false,
        );

        // Act
        notificationsState.setNotifications = [notificationWithNullPostId];

        // Assert
        expect(notificationsState.notifications.first.postId, isNull);
      });

      test('should handle repository returning empty list', () async {
        // Arrange
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => []);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        expect(notificationsState.status, NotificationsStatus.loaded);
        expect(notificationsState.notifications, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => []);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        verify(mockNotificationsRepository.readUserNotifs(
          userId: 'currentUser',
          excludedSourceIds: blockedUsers,
        )).called(1);
      });

      test('should handle mix of read and unread notifications', () async {
        // Arrange
        final mixedNotifications = [
          sampleNotifications[0], // unread
          sampleNotifications[2], // read
          sampleNotifications[1], // unread
        ];
        notificationsState.setNotifications = List.from(mixedNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        expect(notificationsState.notifications.every((n) => n.read), true);
        // Should only be called for the 2 unread notifications
        verify(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).called(2);
      });

      test('should handle different notification types', () {
        // Arrange
        final differentTypes = [
          Notif(
            uid: 'notif_like',
            postId: 'post1',
            targetId: 'currentUser',
            sourceId: 'user1',
            sourceDisplayName: 'User One',
            sourceProfilePictureURL: null,
            type: 'like',
            dateTime: DateTime(2024, 12, 15),
            read: false,
          ),
          Notif(
            uid: 'notif_comment',
            postId: 'post2',
            targetId: 'currentUser',
            sourceId: 'user2',
            sourceDisplayName: 'User Two',
            sourceProfilePictureURL: null,
            type: 'comment',
            dateTime: DateTime(2024, 12, 14),
            read: false,
          ),
          Notif(
            uid: 'notif_follow',
            postId: null,
            targetId: 'currentUser',
            sourceId: 'user3',
            sourceDisplayName: 'User Three',
            sourceProfilePictureURL: null,
            type: 'follow',
            dateTime: DateTime(2024, 12, 13),
            read: false,
          ),
        ];

        // Act
        notificationsState.setNotifications = differentTypes;

        // Assert
        expect(notificationsState.notifications[0].type, 'like');
        expect(notificationsState.notifications[1].type, 'comment');
        expect(notificationsState.notifications[2].type, 'follow');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading notifications', () async {
        // Arrange
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
        )).thenAnswer((_) async => sampleNotifications);

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        // Act
        await notificationsState.getUserNotifications();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating notifications', () async {
        // Arrange
        notificationsState.setNotifications = sampleNotifications;
        when(mockNotificationsRepository.readUserNotifs(
          userId: anyNamed('userId'),
          excludedSourceIds: anyNamed('excludedSourceIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        // Act
        await notificationsState.paginateUserNotifications();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when marking notification as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        // Act
        await notificationsState.markNotificationAsRead(sampleNotifications[0]);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when marking all notifications as read', () async {
        // Arrange
        notificationsState.setNotifications = List.from(sampleNotifications);
        when(mockNotificationsRepository.updateNotif(
          notification: anyNamed('notification'),
        )).thenAnswer((_) async => {});

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        // Act
        await notificationsState.markAllNotificationsAsRead();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting notifications', () {
        bool notified = false;
        notificationsState.addListener(() => notified = true);

        notificationsState.setNotifications = sampleNotifications;

        expect(notified, true);
      });

      test('should notify listeners when adding notifications', () {
        notificationsState.setNotifications = [sampleNotifications.first];

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        notificationsState.addNotifications = [sampleNotifications[1]];

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        notificationsState.addListener(() => notified = true);

        notificationsState.setStatus = NotificationsStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        notificationsState.addListener(() => notified = true);

        notificationsState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        notificationsState.setNotifications = sampleNotifications;

        bool notified = false;
        notificationsState.addListener(() => notified = true);

        notificationsState.reset();

        expect(notified, true);
      });
    });
  });
}
