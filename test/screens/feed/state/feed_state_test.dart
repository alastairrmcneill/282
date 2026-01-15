import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'feed_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  PostsRepository,
  UserState,
  UserLikeState,
  Analytics,
  Logger,
])
void main() {
  late MockPostsRepository mockPostsRepository;
  late MockUserState mockUserState;
  late MockUserLikeState mockUserLikeState;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late FeedState feedState;

  late List<Post> sampleFriendsPosts;
  late List<Post> sampleGlobalPosts;
  late AppUser currentUser;

  setUp(() {
    // Sample current user
    currentUser = AppUser(
      uid: 'currentUser',
      displayName: 'Current User',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample friends posts for testing
    sampleFriendsPosts = [
      Post(
        uid: 'post1',
        authorId: 'friend1',
        authorDisplayName: 'Friend One',
        authorProfilePictureURL: 'https://example.com/friend1.jpg',
        title: 'My First Munro',
        description: 'Amazing hike today!',
        dateTimeCreated: DateTime(2024, 1, 15),
        likes: 5,
        includedMunroIds: [1, 2],
      ),
      Post(
        uid: 'post2',
        authorId: 'friend2',
        authorDisplayName: 'Friend Two',
        authorProfilePictureURL: 'https://example.com/friend2.jpg',
        title: 'Weekend Adventure',
        description: 'Great weather for hiking',
        dateTimeCreated: DateTime(2024, 1, 14),
        likes: 10,
        includedMunroIds: [3],
      ),
      Post(
        uid: 'post3',
        authorId: 'friend3',
        authorDisplayName: 'Friend Three',
        authorProfilePictureURL: null,
        title: 'Summit Success',
        description: null,
        dateTimeCreated: DateTime(2024, 1, 13),
        likes: 3,
        includedMunroIds: [],
      ),
    ];

    // Sample global posts for testing
    sampleGlobalPosts = [
      Post(
        uid: 'global1',
        authorId: 'user1',
        authorDisplayName: 'User One',
        authorProfilePictureURL: 'https://example.com/user1.jpg',
        title: 'Global Post 1',
        description: 'This is a global post',
        dateTimeCreated: DateTime(2024, 1, 20),
        likes: 15,
        includedMunroIds: [4, 5],
      ),
      Post(
        uid: 'global2',
        authorId: 'user2',
        authorDisplayName: 'User Two',
        authorProfilePictureURL: 'https://example.com/user2.jpg',
        title: 'Global Post 2',
        description: 'Another global post',
        dateTimeCreated: DateTime(2024, 1, 19),
        likes: 8,
        includedMunroIds: [6],
      ),
    ];

    mockPostsRepository = MockPostsRepository();
    mockUserState = MockUserState();
    mockUserLikeState = MockUserLikeState();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();
    feedState = FeedState(
      mockPostsRepository,
      mockUserState,
      mockUserLikeState,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(currentUser);
    when(mockUserState.blockedUsers).thenReturn([]);

    // Default mock behavior for UserLikeState
    when(mockUserLikeState.reset()).thenReturn(null);
    when(mockUserLikeState.getLikedPostIds(posts: anyNamed('posts'))).thenAnswer((_) async {});
  });

  group('FeedState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(feedState.status, FeedStatus.initial);
        expect(feedState.error, isA<Error>());
        expect(feedState.friendsPosts, isEmpty);
        expect(feedState.globalPosts, isEmpty);
      });
    });

    group('getFriendsFeed', () {
      test('should load friends feed successfully', () async {
        // Arrange
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleFriendsPosts);

        // Act
        await feedState.getFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.loaded);
        expect(feedState.friendsPosts, sampleFriendsPosts);
        expect(feedState.friendsPosts.length, 3);
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: [],
        )).called(1);
        verify(mockUserLikeState.reset()).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: sampleFriendsPosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleFriendsPosts);

        // Act
        await feedState.getFriendsFeed();

        // Assert
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: blockedUsers,
        )).called(1);
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await feedState.getFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'Log in and follow fellow munro baggers to see their posts.');
        verifyNever(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        ));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenThrow(Exception('Network error'));

        // Act
        await feedState.getFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'There was an issue retreiving your posts. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleFriendsPosts;
        });

        // Act
        final future = feedState.getFriendsFeed();

        // Assert intermediate state
        expect(feedState.status, FeedStatus.loading);

        // Wait for completion
        await future;
        expect(feedState.status, FeedStatus.loaded);
      });
    });

    group('paginateFriendsFeed', () {
      test('should paginate friends feed successfully', () async {
        // Set initial posts - use a copy to avoid mutating sampleFriendsPosts
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);

        // Arrange
        final additionalPosts = [
          Post(
            uid: 'post4',
            authorId: 'friend4',
            authorDisplayName: 'Friend Four',
            authorProfilePictureURL: 'https://example.com/friend4.jpg',
            title: 'New Post',
            description: 'Another adventure',
            dateTimeCreated: DateTime(2024, 1, 12),
            likes: 7,
            includedMunroIds: [7],
          ),
        ];

        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalPosts);

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.loaded);
        expect(feedState.friendsPosts.length, 4);
        expect(feedState.friendsPosts.last.title, 'New Post');
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: [],
          offset: 3,
        )).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: additionalPosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'Log in and follow fellow munro baggers to see their posts.');
        verifyNever(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
      });

      test('should handle error during pagination', () async {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial post count
        final initialCount = feedState.friendsPosts.length;

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'There was an issue loading your feed. Please try again.');
        // Original posts should remain unchanged
        expect(feedState.friendsPosts.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = feedState.paginateFriendsFeed();

        // Assert intermediate state
        expect(feedState.status, FeedStatus.paginating);

        // Wait for completion
        await future;
        expect(feedState.status, FeedStatus.loaded);
      });
    });

    group('getGlobalFeed', () {
      test('should load global feed successfully', () async {
        // Arrange
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleGlobalPosts);

        // Act
        await feedState.getGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.loaded);
        expect(feedState.globalPosts, sampleGlobalPosts);
        expect(feedState.globalPosts.length, 2);
        verify(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: [],
        )).called(1);
        verify(mockUserLikeState.reset()).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: sampleGlobalPosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading', () async {
        // Arrange
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleGlobalPosts);

        // Act
        await feedState.getGlobalFeed();

        // Assert
        verify(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: blockedUsers,
        )).called(1);
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await feedState.getGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'Log in and follow fellow munro baggers to see their posts.');
        verifyNever(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        ));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenThrow(Exception('Database error'));

        // Act
        await feedState.getGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'There was an issue retreiving your posts. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleGlobalPosts;
        });

        // Act
        final future = feedState.getGlobalFeed();

        // Assert intermediate state
        expect(feedState.status, FeedStatus.loading);

        // Wait for completion
        await future;
        expect(feedState.status, FeedStatus.loaded);
      });
    });

    group('paginateGlobalFeed', () {
      test('should paginate global feed successfully', () async {
        // Set initial posts - use a copy to avoid mutating sampleGlobalPosts
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);

        // Arrange
        final additionalPosts = [
          Post(
            uid: 'global3',
            authorId: 'user3',
            authorDisplayName: 'User Three',
            authorProfilePictureURL: 'https://example.com/user3.jpg',
            title: 'Global Post 3',
            description: 'Latest global post',
            dateTimeCreated: DateTime(2024, 1, 18),
            likes: 12,
            includedMunroIds: [8, 9],
          ),
        ];

        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalPosts);

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.loaded);
        expect(feedState.globalPosts.length, 3);
        expect(feedState.globalPosts.last.title, 'Global Post 3');
        verify(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: [],
          offset: 2,
        )).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: additionalPosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        verify(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: blockedUsers,
          offset: 2,
        )).called(1);
      });

      test('should handle null current user', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'Log in and follow fellow munro baggers to see their posts.');
        verifyNever(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
      });

      test('should handle error during pagination', () async {
        // Arrange
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial post count
        final initialCount = feedState.globalPosts.length;

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.error);
        expect(feedState.error.message, 'There was an issue loading your feed. Please try again.');
        // Original posts should remain unchanged
        expect(feedState.globalPosts.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = feedState.paginateGlobalFeed();

        // Assert intermediate state
        expect(feedState.status, FeedStatus.paginating);

        // Wait for completion
        await future;
        expect(feedState.status, FeedStatus.loaded);
      });
    });

    group('Setters', () {
      test('setStatus should update status', () {
        feedState.setStatus = FeedStatus.loading;
        expect(feedState.status, FeedStatus.loading);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        feedState.setError = error;

        expect(feedState.status, FeedStatus.error);
        expect(feedState.error, error);
      });

      test('setFriendsPosts should update friends posts list', () {
        feedState.setFriendsPosts = sampleFriendsPosts;

        expect(feedState.friendsPosts, sampleFriendsPosts);
        expect(feedState.friendsPosts.length, 3);
      });

      test('addFriendsPosts should append to existing friends posts', () {
        feedState.setFriendsPosts = [sampleFriendsPosts.first];

        feedState.addFriendsPosts = [sampleFriendsPosts[1], sampleFriendsPosts[2]];

        expect(feedState.friendsPosts.length, 3);
        expect(feedState.friendsPosts[0], sampleFriendsPosts[0]);
        expect(feedState.friendsPosts[1], sampleFriendsPosts[1]);
        expect(feedState.friendsPosts[2], sampleFriendsPosts[2]);
      });

      test('setGlobalPosts should update global posts list', () {
        feedState.setGlobalPosts = sampleGlobalPosts;

        expect(feedState.globalPosts, sampleGlobalPosts);
        expect(feedState.globalPosts.length, 2);
      });

      test('addGlobalPosts should append to existing global posts', () {
        feedState.setGlobalPosts = [sampleGlobalPosts.first];

        feedState.addGlobalPosts = [sampleGlobalPosts[1]];

        expect(feedState.globalPosts.length, 2);
        expect(feedState.globalPosts[0], sampleGlobalPosts[0]);
        expect(feedState.globalPosts[1], sampleGlobalPosts[1]);
      });
    });

    group('updatePost', () {
      test('should update post in friends feed', () {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        final updatedPost = Post(
          uid: 'post1',
          authorId: 'friend1',
          authorDisplayName: 'Friend One Updated',
          authorProfilePictureURL: 'https://example.com/friend1_new.jpg',
          title: 'Updated Title',
          description: 'Updated description',
          dateTimeCreated: DateTime(2024, 1, 15),
          likes: 50,
          includedMunroIds: [1, 2],
        );

        // Act
        feedState.updatePost(updatedPost);

        // Assert
        expect(feedState.friendsPosts[0].title, 'Updated Title');
        expect(feedState.friendsPosts[0].likes, 50);
        expect(feedState.friendsPosts[0].authorDisplayName, 'Friend One Updated');
      });

      test('should update post in global feed', () {
        // Arrange
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        final updatedPost = Post(
          uid: 'global1',
          authorId: 'user1',
          authorDisplayName: 'User One Updated',
          authorProfilePictureURL: 'https://example.com/user1_new.jpg',
          title: 'Updated Global Post',
          description: 'Updated global description',
          dateTimeCreated: DateTime(2024, 1, 20),
          likes: 100,
          includedMunroIds: [4, 5],
        );

        // Act
        feedState.updatePost(updatedPost);

        // Assert
        expect(feedState.globalPosts[0].title, 'Updated Global Post');
        expect(feedState.globalPosts[0].likes, 100);
        expect(feedState.globalPosts[0].authorDisplayName, 'User One Updated');
      });

      test('should update post in both feeds if present', () {
        // Arrange
        final sharedPost = Post(
          uid: 'shared1',
          authorId: 'shared',
          authorDisplayName: 'Shared User',
          title: 'Original Title',
          dateTimeCreated: DateTime(2024, 1, 10),
          likes: 5,
        );
        feedState.setFriendsPosts = [sharedPost];
        feedState.setGlobalPosts = [sharedPost];

        final updatedPost = Post(
          uid: 'shared1',
          authorId: 'shared',
          authorDisplayName: 'Shared User',
          title: 'Updated Title',
          dateTimeCreated: DateTime(2024, 1, 10),
          likes: 20,
        );

        // Act
        feedState.updatePost(updatedPost);

        // Assert
        expect(feedState.friendsPosts[0].title, 'Updated Title');
        expect(feedState.friendsPosts[0].likes, 20);
        expect(feedState.globalPosts[0].title, 'Updated Title');
        expect(feedState.globalPosts[0].likes, 20);
      });

      test('should not update if post not found', () {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        final nonExistentPost = Post(
          uid: 'nonexistent',
          authorId: 'unknown',
          authorDisplayName: 'Unknown',
          title: 'Unknown Post',
          dateTimeCreated: DateTime(2024, 1, 1),
        );

        // Act
        feedState.updatePost(nonExistentPost);

        // Assert
        expect(feedState.friendsPosts.length, 3);
        expect(feedState.globalPosts.length, 2);
        expect(feedState.friendsPosts, sampleFriendsPosts);
        expect(feedState.globalPosts, sampleGlobalPosts);
      });
    });

    group('removePost', () {
      test('should remove post from friends feed', () {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        final postToRemove = sampleFriendsPosts[1];

        // Act
        feedState.removePost(postToRemove);

        // Assert
        expect(feedState.friendsPosts.length, 2);
        expect(feedState.friendsPosts.contains(postToRemove), false);
      });

      test('should remove post from global feed', () {
        // Arrange
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        final postToRemove = sampleGlobalPosts[0];

        // Act
        feedState.removePost(postToRemove);

        // Assert
        expect(feedState.globalPosts.length, 1);
        expect(feedState.globalPosts.contains(postToRemove), false);
      });

      test('should remove post from both feeds if present', () {
        // Arrange
        final sharedPost = Post(
          uid: 'shared1',
          authorId: 'shared',
          authorDisplayName: 'Shared User',
          title: 'Shared Post',
          dateTimeCreated: DateTime(2024, 1, 10),
        );
        feedState.setFriendsPosts = [sharedPost, sampleFriendsPosts[0]];
        feedState.setGlobalPosts = [sharedPost, sampleGlobalPosts[0]];

        // Act
        feedState.removePost(sharedPost);

        // Assert
        expect(feedState.friendsPosts.length, 1);
        expect(feedState.globalPosts.length, 1);
        expect(feedState.friendsPosts.contains(sharedPost), false);
        expect(feedState.globalPosts.contains(sharedPost), false);
      });

      test('should handle removing non-existent post', () {
        // Arrange
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);
        feedState.setGlobalPosts = List.from(sampleGlobalPosts);
        final nonExistentPost = Post(
          uid: 'nonexistent',
          authorId: 'unknown',
          authorDisplayName: 'Unknown',
          title: 'Unknown Post',
          dateTimeCreated: DateTime(2024, 1, 1),
        );

        // Act
        feedState.removePost(nonExistentPost);

        // Assert
        expect(feedState.friendsPosts.length, 3);
        expect(feedState.globalPosts.length, 2);
      });
    });

    group('Edge Cases', () {
      test('should handle empty friends posts list on pagination', () async {
        // Arrange - start with empty list
        expect(feedState.friendsPosts, isEmpty);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleFriendsPosts);

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        expect(feedState.friendsPosts, sampleFriendsPosts);
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle empty global posts list on pagination', () async {
        // Arrange - start with empty list
        expect(feedState.globalPosts, isEmpty);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleGlobalPosts);

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        expect(feedState.globalPosts, sampleGlobalPosts);
        verify(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs in posts', () {
        // Arrange
        final postWithNullURL = Post(
          uid: 'nullPost',
          authorId: 'user',
          authorDisplayName: 'User',
          authorProfilePictureURL: null,
          title: 'Post without picture',
          description: null,
          dateTimeCreated: DateTime(2024, 1, 1),
        );

        // Act
        feedState.setFriendsPosts = [postWithNullURL];

        // Assert
        expect(feedState.friendsPosts.first.authorProfilePictureURL, isNull);
        expect(feedState.friendsPosts.first.description, isNull);
      });

      test('should handle repository returning empty lists', () async {
        // Arrange
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => []);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => []);

        // Act
        await feedState.getFriendsFeed();
        await feedState.getGlobalFeed();

        // Assert
        expect(feedState.status, FeedStatus.loaded);
        expect(feedState.friendsPosts, isEmpty);
        expect(feedState.globalPosts, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => []);
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => []);

        // Act
        await feedState.getFriendsFeed();

        // Assert
        verify(mockPostsRepository.getFriendsFeedFromUserId(
          userId: 'currentUser',
          excludedAuthorIds: blockedUsers,
        )).called(1);
      });

      test('should handle posts with empty munro lists', () {
        // Arrange
        final postWithNoMunros = Post(
          uid: 'noMunros',
          authorId: 'user',
          authorDisplayName: 'User',
          title: 'Post without munros',
          dateTimeCreated: DateTime(2024, 1, 1),
          includedMunroIds: [],
        );

        // Act
        feedState.setFriendsPosts = [postWithNoMunros];

        // Assert
        expect(feedState.friendsPosts.first.includedMunroIds, isEmpty);
      });

      test('should handle posts with multiple munros', () {
        // Arrange
        final postWithManyMunros = Post(
          uid: 'manyMunros',
          authorId: 'user',
          authorDisplayName: 'User',
          title: 'Multi-munro day',
          dateTimeCreated: DateTime(2024, 1, 1),
          includedMunroIds: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        );

        // Act
        feedState.setFriendsPosts = [postWithManyMunros];

        // Assert
        expect(feedState.friendsPosts.first.includedMunroIds.length, 10);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading friends feed', () async {
        // Arrange
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleFriendsPosts);

        bool notified = false;
        feedState.addListener(() => notified = true);

        // Act
        await feedState.getFriendsFeed();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating friends feed', () async {
        // Arrange
        feedState.setFriendsPosts = sampleFriendsPosts;
        when(mockPostsRepository.getFriendsFeedFromUserId(
          userId: anyNamed('userId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        feedState.addListener(() => notified = true);

        // Act
        await feedState.paginateFriendsFeed();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when loading global feed', () async {
        // Arrange
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
        )).thenAnswer((_) async => sampleGlobalPosts);

        bool notified = false;
        feedState.addListener(() => notified = true);

        // Act
        await feedState.getGlobalFeed();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating global feed', () async {
        // Arrange
        feedState.setGlobalPosts = sampleGlobalPosts;
        when(mockPostsRepository.getGlobalFeed(
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        feedState.addListener(() => notified = true);

        // Act
        await feedState.paginateGlobalFeed();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when setting friends posts', () {
        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.setFriendsPosts = sampleFriendsPosts;

        expect(notified, true);
      });

      test('should notify listeners when setting global posts', () {
        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.setGlobalPosts = sampleGlobalPosts;

        expect(notified, true);
      });

      test('should notify listeners when adding friends posts', () {
        feedState.setFriendsPosts = [sampleFriendsPosts.first];

        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.addFriendsPosts = [sampleFriendsPosts[1]];

        expect(notified, true);
      });

      test('should notify listeners when adding global posts', () {
        feedState.setGlobalPosts = [sampleGlobalPosts.first];

        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.addGlobalPosts = [sampleGlobalPosts[1]];

        expect(notified, true);
      });

      test('should notify listeners when status changes', () {
        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.setStatus = FeedStatus.loading;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when updating post', () {
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);

        bool notified = false;
        feedState.addListener(() => notified = true);

        final updatedPost = Post(
          uid: 'post1',
          authorId: 'friend1',
          authorDisplayName: 'Friend One',
          title: 'Updated Title',
          dateTimeCreated: DateTime(2024, 1, 15),
        );
        feedState.updatePost(updatedPost);

        expect(notified, true);
      });

      test('should notify listeners when removing post', () {
        feedState.setFriendsPosts = List.from(sampleFriendsPosts);

        bool notified = false;
        feedState.addListener(() => notified = true);

        feedState.removePost(sampleFriendsPosts[0]);

        expect(notified, true);
      });
    });
  });
}
