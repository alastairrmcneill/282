import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'comments_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  CommentsRepository,
  UserState,
  PostsRepository,
  Analytics,
  Logger,
])
void main() {
  late MockCommentsRepository mockCommentsRepository;
  late MockUserState mockUserState;
  late MockPostsRepository mockPostsRepository;
  late MockAnalytics mockAnalytics;
  late MockLogger mockLogger;
  late CommentsState commentsState;

  late List<Comment> sampleComments;
  late Post samplePost;
  late AppUser sampleUser;

  setUp(() {
    // Sample user data for testing
    sampleUser = AppUser(
      uid: 'currentUserId',
      displayName: 'Current User',
      profilePictureURL: 'https://example.com/current.jpg',
    );

    // Sample post data for testing
    samplePost = Post(
      uid: 'post123',
      authorId: 'author1',
      authorDisplayName: 'Post Author',
      authorProfilePictureURL: 'https://example.com/author.jpg',
      dateTimeCreated: DateTime.now().subtract(Duration(days: 1)),
      title: 'Test Post',
      description: 'This is a test post',
      likes: 10,
      privacy: Privacy.public,
    );

    // Sample comments data for testing
    sampleComments = [
      Comment(
        uid: 'comment1',
        postId: 'post123',
        authorId: 'user1',
        authorDisplayName: 'User One',
        authorProfilePictureURL: 'https://example.com/user1.jpg',
        dateTime: DateTime.now().subtract(Duration(hours: 2)),
        commentText: 'Great post!',
      ),
      Comment(
        uid: 'comment2',
        postId: 'post123',
        authorId: 'user2',
        authorDisplayName: 'User Two',
        authorProfilePictureURL: 'https://example.com/user2.jpg',
        dateTime: DateTime.now().subtract(Duration(hours: 1)),
        commentText: 'Thanks for sharing!',
      ),
      Comment(
        uid: 'comment3',
        postId: 'post123',
        authorId: 'user3',
        authorDisplayName: 'User Three',
        authorProfilePictureURL: null,
        dateTime: DateTime.now().subtract(Duration(minutes: 30)),
        commentText: 'Interesting perspective.',
      ),
    ];

    mockCommentsRepository = MockCommentsRepository();
    mockUserState = MockUserState();
    mockPostsRepository = MockPostsRepository();
    mockAnalytics = MockAnalytics();
    mockLogger = MockLogger();

    commentsState = CommentsState(
      mockCommentsRepository,
      mockUserState,
      mockPostsRepository,
      mockAnalytics,
      mockLogger,
    );

    // Default mock behavior for UserState
    when(mockUserState.currentUser).thenReturn(sampleUser);
    when(mockUserState.blockedUsers).thenReturn([]);

    // Reset the state to ensure clean slate for each test
    commentsState.reset();
  });

  group('CommentsState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(commentsState.status, CommentsStatus.initial);
        expect(commentsState.error, isA<Error>());
        expect(commentsState.comments, isEmpty);
        expect(commentsState.commentText, isNull);
      });
    });

    group('createComment', () {
      test('should create comment successfully', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setCommentText = 'This is a new comment';

        when(mockCommentsRepository.create(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        // Act
        await commentsState.createComment();

        // Assert
        expect(commentsState.status, CommentsStatus.loaded);
        expect(commentsState.comments.length, 1);
        expect(commentsState.comments.first.commentText, 'This is a new comment');
        expect(commentsState.commentText, isNull);
        verify(mockCommentsRepository.create(comment: anyNamed('comment'))).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should create comment with correct user details', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setCommentText = 'Test comment';

        when(mockCommentsRepository.create(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        // Act
        await commentsState.createComment();

        // Assert
        final createdComment = commentsState.comments.first;
        expect(createdComment.postId, 'post123');
        expect(createdComment.authorId, 'currentUserId');
        expect(createdComment.authorDisplayName, 'Current User');
        expect(createdComment.authorProfilePictureURL, 'https://example.com/current.jpg');
        expect(createdComment.commentText, 'Test comment');
      });

      test('should handle error during comment creation', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setCommentText = 'Test comment';

        when(mockCommentsRepository.create(comment: anyNamed('comment'))).thenThrow(Exception('Network error'));

        // Act
        await commentsState.createComment();

        // Assert
        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error.message, 'There was an issue posting your comment. Please try again');
        expect(commentsState.comments, isEmpty);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });
    });

    group('getPostComments', () {
      test('should load comments and post successfully', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleComments);

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => samplePost);

        // Act
        await commentsState.getPostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.loaded);
        expect(commentsState.comments, sampleComments);
        expect(commentsState.post, samplePost);
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
        verify(mockPostsRepository.readPostFromUid(uid: 'post123')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when loading comments', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        final blockedUsers = ['blockedUser1', 'blockedUser2'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleComments);

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => samplePost);

        // Act
        await commentsState.getPostComments();

        // Assert
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle error during loading comments', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Database error'));

        // Act
        await commentsState.getPostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error.message, 'There was an issue retreiving the comments. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should handle error during loading post', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleComments);

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenThrow(Exception('Post not found'));

        // Act
        await commentsState.getPostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error.message, 'There was an issue retreiving the comments. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleComments;
        });

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => samplePost);

        // Act
        final future = commentsState.getPostComments();

        // Assert intermediate state
        expect(commentsState.status, CommentsStatus.loading);

        // Wait for completion
        await future;
        expect(commentsState.status, CommentsStatus.loaded);
      });

      test('should return early if currentUser is null', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await commentsState.getPostComments();

        // Assert
        verifyNever(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
        verifyNever(mockPostsRepository.readPostFromUid(uid: anyNamed('uid')));
      });
    });

    group('paginatePostComments', () {
      test('should paginate comments successfully', () async {
        // Set initial comments - use a copy to avoid mutating sampleComments
        commentsState.setPostId = 'post123';
        commentsState.setComments = List.from(sampleComments);

        // Arrange
        final additionalComments = [
          Comment(
            uid: 'comment4',
            postId: 'post123',
            authorId: 'user4',
            authorDisplayName: 'User Four',
            authorProfilePictureURL: 'https://example.com/user4.jpg',
            dateTime: DateTime.now(),
            commentText: 'Another comment',
          ),
        ];

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => additionalComments);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.loaded);
        expect(commentsState.comments.length, 4);
        expect(commentsState.comments.last.authorDisplayName, 'User Four');
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: [],
          offset: 3,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users when paginating', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setComments = List.from(sampleComments);
        final blockedUsers = ['blockedUser1'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: blockedUsers,
          offset: 3,
        )).called(1);
      });

      test('should handle error during pagination', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setComments = List.from(sampleComments);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenThrow(Exception('Pagination error'));

        // Store initial comment count
        final initialCount = commentsState.comments.length;

        // Act
        await commentsState.paginatePostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error.message, 'There was an issue retreiving the comments. Please try again.');
        // Original comments should remain unchanged
        expect(commentsState.comments.length, initialCount);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to paginating during async operation', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setComments = List.from(sampleComments);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return [];
        });

        // Act
        final future = commentsState.paginatePostComments();

        // Assert intermediate state
        expect(commentsState.status, CommentsStatus.paginating);

        // Wait for completion
        await future;
        expect(commentsState.status, CommentsStatus.loaded);
      });

      test('should return early if currentUser is null', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        when(mockUserState.currentUser).thenReturn(null);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        verifyNever(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        ));
      });
    });

    group('deleteComment', () {
      test('should delete comment from list and repository', () async {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentToDelete = sampleComments[1];

        when(mockCommentsRepository.deleteComment(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        // Act
        await commentsState.deleteComment(comment: commentToDelete);

        // Assert
        expect(commentsState.comments.length, 2);
        expect(commentsState.comments.contains(commentToDelete), false);
        verify(mockCommentsRepository.deleteComment(comment: commentToDelete)).called(1);
      });

      test('should handle deleting comment not in list', () async {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentNotInList = Comment(
          uid: 'comment999',
          postId: 'post123',
          authorId: 'user999',
          authorDisplayName: 'User 999',
          authorProfilePictureURL: null,
          dateTime: DateTime.now(),
          commentText: 'Not in list',
        );

        when(mockCommentsRepository.deleteComment(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        // Store initial count
        final initialCount = commentsState.comments.length;

        // Act
        await commentsState.deleteComment(comment: commentNotInList);

        // Assert
        expect(commentsState.comments.length, initialCount);
        verify(mockCommentsRepository.deleteComment(comment: commentNotInList)).called(1);
      });

      test('should handle error during deletion', () async {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentToDelete = sampleComments[0];

        when(mockCommentsRepository.deleteComment(comment: anyNamed('comment'))).thenThrow(Exception('Delete error'));

        // Act
        await commentsState.deleteComment(comment: commentToDelete);

        // Assert
        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error.message, 'There was an issue deleting the comment. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should remove from UI before repository call', () async {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentToDelete = sampleComments[1];
        final initialCount = commentsState.comments.length;

        when(mockCommentsRepository.deleteComment(comment: anyNamed('comment'))).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
        });

        // Act
        await commentsState.deleteComment(comment: commentToDelete);

        // Assert - comment should be removed even during async operation
        expect(commentsState.comments.length, initialCount - 1);
        expect(commentsState.comments.contains(commentToDelete), false);
      });
    });

    group('removeComment', () {
      test('should remove comment from list if it exists', () {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentToRemove = sampleComments[1];

        // Act
        commentsState.removeComment(commentToRemove);

        // Assert
        expect(commentsState.comments.length, 2);
        expect(commentsState.comments.contains(commentToRemove), false);
      });

      test('should handle removing comment not in list', () {
        // Arrange
        commentsState.setComments = List.from(sampleComments);
        final commentNotInList = Comment(
          uid: 'comment999',
          postId: 'post123',
          authorId: 'user999',
          authorDisplayName: 'User 999',
          authorProfilePictureURL: null,
          dateTime: DateTime.now(),
          commentText: 'Not in list',
        );

        final initialCount = commentsState.comments.length;

        // Act
        commentsState.removeComment(commentNotInList);

        // Assert
        expect(commentsState.comments.length, initialCount);
      });
    });

    group('Setters', () {
      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        commentsState.setError = error;

        expect(commentsState.status, CommentsStatus.error);
        expect(commentsState.error, error);
      });

      test('setPostId should update postId', () {
        commentsState.setPostId = 'newPost123';

        expect(commentsState.postId, 'newPost123');
      });

      test('setPost should update post', () {
        commentsState.setPost = samplePost;

        expect(commentsState.post, samplePost);
        expect(commentsState.post.uid, 'post123');
      });

      test('setCommentText should update commentText', () {
        commentsState.setCommentText = 'New comment text';

        expect(commentsState.commentText, 'New comment text');
      });

      test('setCommentText should handle null', () {
        commentsState.setCommentText = 'Some text';
        commentsState.setCommentText = null;

        expect(commentsState.commentText, isNull);
      });

      test('setComments should update comments list', () {
        commentsState.setComments = sampleComments;

        expect(commentsState.comments, sampleComments);
        expect(commentsState.comments.length, 3);
      });
    });

    group('reset', () {
      test('should reset all state to initial values', () {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setPost = samplePost;
        commentsState.setCommentText = 'Some text';
        commentsState.setComments = sampleComments;

        // Act
        commentsState.reset();

        // Assert
        expect(commentsState.status, CommentsStatus.initial);
        expect(commentsState.error, isA<Error>());
        expect(commentsState.comments, isEmpty);
        expect(commentsState.commentText, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty comments list on pagination', () async {
        // Arrange - start with empty list
        commentsState.setPostId = 'post123';
        expect(commentsState.comments, isEmpty);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleComments);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        expect(commentsState.comments, sampleComments);
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: [],
          offset: 0,
        )).called(1);
      });

      test('should handle null profile picture URLs', () {
        // Arrange
        final commentWithNullURL = Comment(
          uid: 'comment5',
          postId: 'post123',
          authorId: 'user5',
          authorDisplayName: 'User Five',
          authorProfilePictureURL: null,
          dateTime: DateTime.now(),
          commentText: 'Comment without picture',
        );

        // Act
        commentsState.setComments = [commentWithNullURL];

        // Assert
        expect(commentsState.comments.first.authorProfilePictureURL, isNull);
      });

      test('should handle repository returning empty list', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => samplePost);

        // Act
        await commentsState.getPostComments();

        // Assert
        expect(commentsState.status, CommentsStatus.loaded);
        expect(commentsState.comments, isEmpty);
      });

      test('should handle multiple blocked users', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        final blockedUsers = ['blocked1', 'blocked2', 'blocked3', 'blocked4'];
        when(mockUserState.blockedUsers).thenReturn(blockedUsers);

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        verify(mockCommentsRepository.readPostComments(
          postId: 'post123',
          excludedAuthorIds: blockedUsers,
          offset: 0,
        )).called(1);
      });

      test('should handle user with no display name', () async {
        // Arrange
        final userWithoutName = AppUser(
          uid: 'userId',
          displayName: null,
          profilePictureURL: null,
        );
        when(mockUserState.currentUser).thenReturn(userWithoutName);

        commentsState.setPostId = 'post123';
        commentsState.setCommentText = 'Test comment';

        when(mockCommentsRepository.create(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        // Act
        await commentsState.createComment();

        // Assert
        final createdComment = commentsState.comments.first;
        expect(createdComment.authorDisplayName, '');
        expect(createdComment.authorProfilePictureURL, isNull);
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when creating comment', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setCommentText = 'Test';

        when(mockCommentsRepository.create(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        bool notified = false;
        commentsState.addListener(() => notified = true);

        // Act
        await commentsState.createComment();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when loading comments', () async {
        // Arrange
        commentsState.setPostId = 'post123';

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => sampleComments);

        when(mockPostsRepository.readPostFromUid(uid: anyNamed('uid'))).thenAnswer((_) async => samplePost);

        bool notified = false;
        commentsState.addListener(() => notified = true);

        // Act
        await commentsState.getPostComments();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when paginating comments', () async {
        // Arrange
        commentsState.setPostId = 'post123';
        commentsState.setComments = sampleComments;

        when(mockCommentsRepository.readPostComments(
          postId: anyNamed('postId'),
          excludedAuthorIds: anyNamed('excludedAuthorIds'),
          offset: anyNamed('offset'),
        )).thenAnswer((_) async => []);

        bool notified = false;
        commentsState.addListener(() => notified = true);

        // Act
        await commentsState.paginatePostComments();

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when deleting comment', () async {
        // Arrange
        commentsState.setComments = sampleComments;

        when(mockCommentsRepository.deleteComment(comment: anyNamed('comment'))).thenAnswer((_) async => {});

        bool notified = false;
        commentsState.addListener(() => notified = true);

        // Act
        await commentsState.deleteComment(comment: sampleComments.first);

        // Assert
        expect(notified, true);
      });

      test('should notify listeners when removing comment', () {
        commentsState.setComments = sampleComments;

        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.removeComment(sampleComments.first);

        expect(notified, true);
      });

      test('should notify listeners when setting postId', () {
        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.setPostId = 'newPost';

        expect(notified, true);
      });

      test('should notify listeners when setting post', () {
        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.setPost = samplePost;

        expect(notified, true);
      });

      test('should notify listeners when setting commentText', () {
        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.setCommentText = 'New text';

        expect(notified, true);
      });

      test('should notify listeners when setting comments', () {
        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.setComments = sampleComments;

        expect(notified, true);
      });

      test('should notify listeners when error occurs', () {
        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.setError = Error(message: 'test error');

        expect(notified, true);
      });

      test('should notify listeners when resetting', () {
        commentsState.setComments = sampleComments;

        bool notified = false;
        commentsState.addListener(() => notified = true);

        commentsState.reset();

        expect(notified, true);
      });
    });
  });
}
