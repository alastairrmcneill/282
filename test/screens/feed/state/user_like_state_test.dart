import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'user_like_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  LikesRepository,
  UserState,
  Logger,
])
void main() {
  late MockLikesRepository mockLikesRepository;
  late MockUserState mockUserState;
  late MockLogger mockLogger;
  late UserLikeState userLikeState;

  late AppUser currentUser;
  late Post samplePost;
  late List<Post> samplePosts;

  setUp(() {
    // Sample user data for testing
    currentUser = AppUser(
      uid: 'currentUserId',
      displayName: 'Current User',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample post data for testing
    samplePost = Post(
      uid: 'post1',
      authorId: 'author1',
      authorDisplayName: 'Author One',
      authorProfilePictureURL: 'https://example.com/author1.jpg',
      title: 'Test Post',
      description: 'This is a test post',
      likes: 5,
      privacy: Privacy.public,
    );

    samplePosts = [
      samplePost,
      Post(
        uid: 'post2',
        authorId: 'author2',
        authorDisplayName: 'Author Two',
        title: 'Test Post 2',
        likes: 3,
      ),
      Post(
        uid: 'post3',
        authorId: 'author3',
        authorDisplayName: 'Author Three',
        title: 'Test Post 3',
        likes: 10,
      ),
    ];

    mockLikesRepository = MockLikesRepository();
    mockUserState = MockUserState();
    mockLogger = MockLogger();
    userLikeState = UserLikeState(
      mockLikesRepository,
      mockUserState,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(currentUser);

    // Reset the state to ensure clean slate for each test
    userLikeState.reset();
  });

  group('UserLikeState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(userLikeState.status, UserLikeStatus.initial);
        expect(userLikeState.error, isA<Error>());
        expect(userLikeState.likedPosts, isEmpty);
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
      });
    });

    group('likePost', () {
      test('should like post successfully', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        Post updatedPost = samplePost;
        void onPostUpdated(Post newPost) {
          updatedPost = newPost;
        }

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: onPostUpdated,
        );

        // Assert
        expect(userLikeState.likedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyLikedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
        expect(updatedPost.likes, samplePost.likes + 1);
        verify(mockLikesRepository.create(like: anyNamed('like'))).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should create like with correct data', () async {
        // Arrange
        Like? capturedLike;
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((invocation) async {
          capturedLike = invocation.namedArguments[#like];
        });

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(capturedLike, isNotNull);
        expect(capturedLike!.postId, samplePost.uid);
        expect(capturedLike!.userId, currentUser.uid);
        expect(capturedLike!.userDisplayName, currentUser.displayName);
        expect(capturedLike!.userProfilePictureURL, currentUser.profilePictureURL);
        expect(capturedLike!.dateTimeCreated, isA<DateTime>());
      });

      test('should remove post from recentlyUnlikedPosts if it was previously unliked', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        // First unlike (simulated by adding to recentlyUnlikedPosts)
        userLikeState.recentlyUnlikedPosts.add(samplePost.uid);

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(userLikeState.likedPosts, contains(samplePost.uid));
      });

      test('should call onPostUpdated callback with incremented likes', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        Post? updatedPost;
        void onPostUpdated(Post newPost) {
          updatedPost = newPost;
        }

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: onPostUpdated,
        );

        // Assert
        expect(updatedPost, isNotNull);
        expect(updatedPost!.uid, samplePost.uid);
        expect(updatedPost!.likes, samplePost.likes + 1);
      });

      test('should handle null current user gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        Like? capturedLike;
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((invocation) async {
          capturedLike = invocation.namedArguments[#like];
        });

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(capturedLike!.userId, "");
        expect(capturedLike!.userDisplayName, "User");
        expect(capturedLike!.userProfilePictureURL, isNull);
      });
    });

    group('unLikePost', () {
      test('should unlike post successfully', () async {
        // Arrange
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        // Add post to liked posts first
        userLikeState.likedPosts.add(samplePost.uid);

        Post updatedPost = samplePost;
        void onPostUpdated(Post newPost) {
          updatedPost = newPost;
        }

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: onPostUpdated,
        );

        // Assert
        expect(userLikeState.likedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(updatedPost.likes, samplePost.likes - 1);
        verify(mockLikesRepository.delete(
          postId: samplePost.uid,
          userId: currentUser.uid,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should remove post from recentlyLikedPosts if it was recently liked', () async {
        // Arrange
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        // First like (simulated by adding to recentlyLikedPosts)
        userLikeState.likedPosts.add(samplePost.uid);
        userLikeState.recentlyLikedPosts.add(samplePost.uid);

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
        expect(userLikeState.likedPosts, isEmpty);
      });

      test('should call onPostUpdated callback with decremented likes', () async {
        // Arrange
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        userLikeState.likedPosts.add(samplePost.uid);

        Post? updatedPost;
        void onPostUpdated(Post newPost) {
          updatedPost = newPost;
        }

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: onPostUpdated,
        );

        // Assert
        expect(updatedPost, isNotNull);
        expect(updatedPost!.uid, samplePost.uid);
        expect(updatedPost!.likes, samplePost.likes - 1);
      });

      test('should handle null current user gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        verify(mockLikesRepository.delete(
          postId: samplePost.uid,
          userId: "",
        )).called(1);
      });
    });

    group('getLikedPostIds', () {
      test('should load liked post IDs successfully', () async {
        // Arrange
        final likedPostIds = {'post1', 'post2'};
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => likedPostIds);

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        expect(userLikeState.status, UserLikeStatus.loaded);
        expect(userLikeState.likedPosts, likedPostIds);
        verify(mockLikesRepository.getLikedPostIds(
          userId: currentUser.uid,
          posts: samplePosts,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return <String>{};
        });

        // Act
        final future = userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert intermediate state
        expect(userLikeState.status, UserLikeStatus.loading);

        // Wait for completion
        await future;
        expect(userLikeState.status, UserLikeStatus.loaded);
      });

      test('should add liked post IDs to existing set', () async {
        // Arrange
        userLikeState.likedPosts.add('existingPost');
        final newLikedPostIds = {'post1', 'post2'};
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => newLikedPostIds);

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        expect(userLikeState.likedPosts.length, 3);
        expect(userLikeState.likedPosts, contains('existingPost'));
        expect(userLikeState.likedPosts, contains('post1'));
        expect(userLikeState.likedPosts, contains('post2'));
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenThrow(Exception('Network error'));

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        expect(userLikeState.status, UserLikeStatus.error);
        expect(userLikeState.error.message, 'There was an error loading liked posts.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle null current user gracefully', () async {
        // Arrange
        when(mockUserState.currentUser).thenReturn(null);
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => <String>{});

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        verify(mockLikesRepository.getLikedPostIds(
          userId: "",
          posts: samplePosts,
        )).called(1);
      });

      test('should handle empty posts list', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => <String>{});

        // Act
        await userLikeState.getLikedPostIds(posts: []);

        // Assert
        expect(userLikeState.status, UserLikeStatus.loaded);
        expect(userLikeState.likedPosts, isEmpty);
      });
    });

    group('setError', () {
      test('should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        userLikeState.setError = error;

        expect(userLikeState.status, UserLikeStatus.error);
        expect(userLikeState.error, error);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        userLikeState.likedPosts.add('post1');
        userLikeState.recentlyLikedPosts.add('post2');
        userLikeState.recentlyUnlikedPosts.add('post3');
        userLikeState.setError = Error(message: 'test error');

        // Act
        userLikeState.reset();

        // Assert
        expect(userLikeState.status, UserLikeStatus.initial);
        expect(userLikeState.error, isA<Error>());
        expect(userLikeState.likedPosts, isEmpty);
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle liking the same post multiple times', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.likedPosts.length, 1);
        expect(userLikeState.likedPosts, contains(samplePost.uid));
      });

      test('should handle unliking a post that was not liked', () async {
        // Arrange
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.likedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, contains(samplePost.uid));
      });

      test('should handle like/unlike/like sequence correctly', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );
        expect(userLikeState.recentlyLikedPosts, contains(samplePost.uid));

        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );
        expect(userLikeState.recentlyLikedPosts, isEmpty);
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);

        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.likedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyLikedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
      });

      test('should handle repository returning empty set', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => <String>{});

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        expect(userLikeState.status, UserLikeStatus.loaded);
        expect(userLikeState.likedPosts, isEmpty);
      });

      test('should handle post with null author profile picture', () async {
        // Arrange
        final postWithNullPicture = Post(
          uid: 'post4',
          authorId: 'author4',
          authorDisplayName: 'Author Four',
          authorProfilePictureURL: null,
          title: 'Test Post',
          likes: 0,
        );

        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        // Act
        await userLikeState.likePost(
          post: postWithNullPicture,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(userLikeState.likedPosts, contains(postWithNullPicture.uid));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when liking a post', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        bool notified = false;
        userLikeState.addListener(() => notified = true);

        // Act
        await userLikeState.likePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when unliking a post', () async {
        // Arrange
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) async => {});

        userLikeState.likedPosts.add(samplePost.uid);

        bool notified = false;
        userLikeState.addListener(() => notified = true);

        // Act
        await userLikeState.unLikePost(
          post: samplePost,
          onPostUpdated: (newPost) {},
        );

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when loading liked post IDs', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async => <String>{});

        bool notified = false;
        userLikeState.addListener(() => notified = true);

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        userLikeState.addListener(() => notified = true);

        userLikeState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        userLikeState.likedPosts.add('post1');

        bool notified = false;
        userLikeState.addListener(() => notified = true);

        userLikeState.reset();

        expect(notified, true);
      });

      test('should notify listeners multiple times during getLikedPostIds', () async {
        // Arrange
        when(mockLikesRepository.getLikedPostIds(
          userId: anyNamed('userId'),
          posts: anyNamed('posts'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 50));
          return {'post1'};
        });

        int notificationCount = 0;
        userLikeState.addListener(() => notificationCount++);

        // Act
        await userLikeState.getLikedPostIds(posts: samplePosts);

        // Assert - Should notify at least twice (loading and loaded)
        expect(notificationCount, greaterThanOrEqualTo(2));
      });
    });

    group('Integration Scenarios', () {
      test('should handle multiple posts being liked in sequence', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenAnswer((_) async => {});

        // Act
        for (final post in samplePosts) {
          await userLikeState.likePost(
            post: post,
            onPostUpdated: (newPost) {},
          );
        }

        // Assert
        expect(userLikeState.likedPosts.length, 3);
        expect(userLikeState.recentlyLikedPosts.length, 3);
        for (final post in samplePosts) {
          expect(userLikeState.likedPosts, contains(post.uid));
        }
      });

      test('should not update state when repository fails during like', () async {
        // Arrange
        when(mockLikesRepository.create(like: anyNamed('like'))).thenThrow(Exception('Network error'));

        // Act & Assert
        try {
          await userLikeState.likePost(
            post: samplePost,
            onPostUpdated: (newPost) {},
          );
          fail('Should have thrown an exception');
        } catch (e) {
          // Exception should propagate
          expect(e, isA<Exception>());
        }

        // State should not be updated since repository call failed
        expect(userLikeState.likedPosts, isEmpty);
        expect(userLikeState.recentlyLikedPosts, isEmpty);
      });

      test('should not update state when repository fails during unlike', () async {
        // Arrange
        userLikeState.likedPosts.add(samplePost.uid);
        when(mockLikesRepository.delete(
          postId: anyNamed('postId'),
          userId: anyNamed('userId'),
        )).thenThrow(Exception('Network error'));

        // Act & Assert
        try {
          await userLikeState.unLikePost(
            post: samplePost,
            onPostUpdated: (newPost) {},
          );
          fail('Should have thrown an exception');
        } catch (e) {
          // Exception should propagate
          expect(e, isA<Exception>());
        }

        // State should not be updated since repository call failed
        expect(userLikeState.likedPosts, contains(samplePost.uid));
        expect(userLikeState.recentlyUnlikedPosts, isEmpty);
      });
    });
  });
}
