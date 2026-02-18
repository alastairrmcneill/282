import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

import 'profile_state_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ProfileRepository,
  MunroPicturesRepository,
  PostsRepository,
  UserState,
  UserLikeState,
  MunroCompletionsRepository,
  Logger,
])
void main() {
  late MockProfileRepository mockProfileRepository;
  late MockMunroPicturesRepository mockMunroPicturesRepository;
  late MockPostsRepository mockPostsRepository;
  late MockUserState mockUserState;
  late MockUserLikeState mockUserLikeState;
  late MockMunroCompletionsRepository mockMunroCompletionsRepository;
  late MockLogger mockLogger;
  late ProfileState profileState;

  // Sample data - recreated fresh for each test
  late Profile sampleProfile;
  late AppUser sampleCurrentUser;
  late List<Post> samplePosts;
  late List<MunroPicture> sampleMunroPictures;
  late List<MunroCompletion> sampleMunroCompletions;

  setUp(() {
    // Create fresh sample data for each test
    sampleProfile = Profile(
      id: 'user123',
      firstName: 'John',
      lastName: 'Doe',
      displayName: 'john_doe',
      bio: 'Mountain enthusiast',
      profilePictureURL: 'https://example.com/profile.jpg',
      followersCount: 50,
      followingCount: 75,
      munrosCompleted: 150,
      dateTimeCreated: DateTime(2023, 1, 1),
    );

    sampleCurrentUser = AppUser(
      uid: 'user123',
      displayName: 'john_doe',
      firstName: 'John',
      lastName: 'Doe',
    );

    samplePosts = <Post>[
      Post(
        uid: 'post1',
        authorId: 'user123',
        authorDisplayName: 'john_doe',
        authorProfilePictureURL: 'https://example.com/profile.jpg',
        dateTimeCreated: DateTime(2023, 12, 1),
        title: 'Ben Nevis',
        description: 'Amazing climb today!',
        imageUrlsMap: {
          1: ['https://example.com/image1.jpg']
        },
        includedMunroIds: [1],
        likes: 15,
        privacy: Privacy.public,
      ),
      Post(
        uid: 'post2',
        authorId: 'user123',
        authorDisplayName: 'john_doe',
        authorProfilePictureURL: 'https://example.com/profile.jpg',
        dateTimeCreated: DateTime(2023, 11, 15),
        title: 'Ben Macdui',
        description: 'Challenging but rewarding',
        imageUrlsMap: {
          2: ['https://example.com/image2.jpg']
        },
        includedMunroIds: [2],
        likes: 8,
        privacy: Privacy.public,
      ),
    ];

    sampleMunroPictures = <MunroPicture>[
      MunroPicture(
        uid: 'pic1',
        authorId: 'user123',
        munroId: 1,
        imageUrl: 'https://example.com/munro1.jpg',
        dateTime: DateTime(2023, 12, 1),
        postId: 'post1',
        privacy: Privacy.public,
      ),
      MunroPicture(
        uid: 'pic2',
        authorId: 'user123',
        munroId: 2,
        imageUrl: 'https://example.com/munro2.jpg',
        dateTime: DateTime(2023, 11, 15),
        postId: 'post2',
        privacy: Privacy.public,
      ),
    ];

    sampleMunroCompletions = <MunroCompletion>[
      MunroCompletion(
        id: 'completion1',
        userId: 'user123',
        munroId: 1,
        dateTimeCompleted: DateTime(2023, 12, 1),
        postId: 'post1',
      ),
      MunroCompletion(
        id: 'completion2',
        userId: 'user123',
        munroId: 2,
        dateTimeCompleted: DateTime(2023, 11, 15),
        postId: 'post2',
      ),
    ];

    // Create fresh mocks for each test
    mockProfileRepository = MockProfileRepository();
    mockMunroPicturesRepository = MockMunroPicturesRepository();
    mockPostsRepository = MockPostsRepository();
    mockUserState = MockUserState();
    mockUserLikeState = MockUserLikeState();
    mockMunroCompletionsRepository = MockMunroCompletionsRepository();
    mockLogger = MockLogger();

    profileState = ProfileState(
      mockProfileRepository,
      mockMunroPicturesRepository,
      mockPostsRepository,
      mockUserState,
      mockUserLikeState,
      mockMunroCompletionsRepository,
      mockLogger,
    );

    // Set up default mock behaviors
    when(mockUserState.blockedUsers).thenReturn([]);
    when(mockUserLikeState.reset()).thenReturn(null);
    when(mockUserLikeState.getLikedPostIds(posts: anyNamed('posts'))).thenAnswer((_) async {});
  });

  group('ProfileState', () {
    group('Initial State', () {
      test('should have correct initial values', () {
        expect(profileState.status, ProfileStatus.initial);
        expect(profileState.photoStatus, ProfilePhotoStatus.initial);
        expect(profileState.error, isA<Error>());
        expect(profileState.profile, isNull);
        expect(profileState.isCurrentUser, false);
        expect(profileState.posts, isEmpty);
        expect(profileState.profilePhotos, isEmpty);
        expect(profileState.munroCompletions, isEmpty);
      });
    });

    group('loadProfileFromUserId', () {
      test('should load profile successfully for current user', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await profileState.loadProfileFromUserId(userId: 'user123');

        // Assert
        expect(profileState.status, ProfileStatus.loaded);
        expect(profileState.profile, sampleProfile);
        expect(profileState.isCurrentUser, true);
        expect(profileState.posts, samplePosts);
        verify(mockProfileRepository.getProfileFromUserId(userId: 'user123')).called(1);
        verify(mockPostsRepository.readPostsFromUserId(userId: 'user123')).called(1);
        verify(mockUserLikeState.reset()).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: samplePosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should load profile successfully for other user', () async {
        // Arrange
        final otherProfile = Profile(
          id: 'user456',
          firstName: sampleProfile.firstName,
          lastName: sampleProfile.lastName,
          displayName: 'jane_doe',
          bio: sampleProfile.bio,
          profilePictureURL: sampleProfile.profilePictureURL,
          followersCount: sampleProfile.followersCount,
          followingCount: sampleProfile.followingCount,
          munrosCompleted: sampleProfile.munrosCompleted,
          dateTimeCreated: sampleProfile.dateTimeCreated,
        );
        when(mockProfileRepository.getProfileFromUserId(userId: 'user456')).thenAnswer((_) async => otherProfile);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user456')).thenAnswer((_) async => []);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user456',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => []);

        // Act
        await profileState.loadProfileFromUserId(userId: 'user456');

        // Assert
        expect(profileState.status, ProfileStatus.loaded);
        expect(profileState.profile?.id, 'user456');
        expect(profileState.isCurrentUser, false);
        verify(mockProfileRepository.getProfileFromUserId(userId: 'user456')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during profile loading', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenThrow(Exception('Network error'));

        // Act
        await profileState.loadProfileFromUserId(userId: 'user123');

        // Assert
        expect(profileState.status, ProfileStatus.error);
        expect(profileState.error.code, contains('Exception: Network error'));
        expect(profileState.error.message, 'There was an issue loading the profile. Please try again.');
        verify(mockProfileRepository.getProfileFromUserId(userId: 'user123')).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleProfile;
        });
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        final future = profileState.loadProfileFromUserId(userId: 'user123');

        // Assert intermediate state
        expect(profileState.status, ProfileStatus.loading);

        // Wait for completion
        await future;
        expect(profileState.status, ProfileStatus.loaded);
      });
    });

    group('getMunroPictures', () {
      setUp(() {
        profileState.setStatus = ProfileStatus.loaded; // Set up loaded state
      });

      test('should load munro pictures successfully', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        expect(profileState.photoStatus, ProfilePhotoStatus.loaded);
        expect(profileState.profilePhotos, sampleMunroPictures);
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should exclude blocked users', () async {
        // Arrange
        when(mockUserState.blockedUsers).thenReturn(['blockedUser1', 'blockedUser2']);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: ['blockedUser1', 'blockedUser2'],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: ['blockedUser1', 'blockedUser2'],
          offset: 0,
          count: 4,
        )).called(1);
      });

      test('should handle error during loading', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenThrow(Exception('Network error'));

        // Act
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        expect(profileState.error.message, 'There was an issue loading pictures for this profile. Please try again.');
        verify(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set photo status to loading during async operation', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return sampleMunroPictures;
        });

        // Act
        final future = profileState.getMunroPictures(profileId: 'user123');

        // Assert intermediate state
        expect(profileState.photoStatus, ProfilePhotoStatus.loading);

        // Wait for completion
        await future;
        expect(profileState.photoStatus, ProfilePhotoStatus.loaded);
      });
    });

    group('paginateMunroPictures', () {
      setUp(() {
        // No initial setup needed - each test will set up its own mocks
      });
    });

    group('getProfilePosts', () {
      setUp(() async {
        // Load profile first to set up the internal state, then reset mocks
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => []);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).thenAnswer((_) async => []);
        await profileState.loadProfileFromUserId(userId: 'user123');

        // Reset all mocks to clear call counts from setUp
        reset(mockPostsRepository);
        reset(mockUserLikeState);
        reset(mockLogger);

        // Re-establish default behaviors after reset
        when(mockUserLikeState.reset()).thenReturn(null);
        when(mockUserLikeState.getLikedPostIds(posts: anyNamed('posts'))).thenAnswer((_) async {});
      });

      test('should load profile posts successfully', () async {
        // Arrange
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);

        // Act
        await profileState.getProfilePosts();

        // Assert
        expect(profileState.status, ProfileStatus.loaded);
        expect(profileState.posts, samplePosts);
        verify(mockPostsRepository.readPostsFromUserId(userId: 'user123')).called(1);
        verify(mockUserLikeState.reset()).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: samplePosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during posts loading', () async {
        // Arrange
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenThrow(Exception('Network error'));

        // Act
        await profileState.getProfilePosts();

        // Assert
        expect(profileState.error.message, 'There was an retreiving your posts. Please try again.');
        verify(mockPostsRepository.readPostsFromUserId(userId: 'user123')).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(1);
      });

      test('should set status to loading during async operation', () async {
        // Arrange
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return samplePosts;
        });

        // Act
        final future = profileState.getProfilePosts();

        // Assert intermediate state
        expect(profileState.status, ProfileStatus.loading);

        // Wait for completion
        await future;
        expect(profileState.status, ProfileStatus.loaded);
      });
    });

    group('paginateProfilePosts', () {
      setUp(() async {
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => []);

        await profileState.loadProfileFromUserId(userId: 'user123');
      });

      test('should paginate profile posts successfully', () async {
        // Arrange
        final additionalPosts = <Post>[
          Post(
            uid: 'post3',
            authorId: 'user123',
            authorDisplayName: 'john_doe',
            authorProfilePictureURL: 'https://example.com/profile.jpg',
            dateTimeCreated: DateTime(2023, 10, 1),
            title: 'Ben Lomond',
            description: 'Beautiful day for a hike',
            imageUrlsMap: {
              3: ['https://example.com/image3.jpg']
            },
            includedMunroIds: [3],
            likes: 12,
            privacy: Privacy.public,
          ),
        ];

        when(mockPostsRepository.readPostsFromUserId(
          userId: 'user123',
          offset: 2,
        )).thenAnswer((_) async => additionalPosts);

        // Act
        await profileState.paginateProfilePosts();

        // Assert
        expect(profileState.status, ProfileStatus.loaded);
        expect(profileState.posts, hasLength(3));
        expect(profileState.posts.last.uid, 'post3');
        verify(mockPostsRepository.readPostsFromUserId(
          userId: 'user123',
          offset: 2,
        )).called(1);
        verify(mockUserLikeState.getLikedPostIds(posts: additionalPosts)).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during pagination', () async {
        // Arrange
        when(mockPostsRepository.readPostsFromUserId(
          userId: 'user123',
          offset: 2,
        )).thenThrow(Exception('Network error'));

        // Act
        await profileState.paginateProfilePosts();

        // Assert
        expect(profileState.error.message, 'There was an issue loading your posts. Please try again.');
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(greaterThanOrEqualTo(1));
      });
    });

    group('getProfileMunroCompletions', () {
      setUp(() async {
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => []);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => []);
        await profileState.loadProfileFromUserId(userId: 'user123');
      });

      test('should load munro completions successfully', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123'))
            .thenAnswer((_) async => sampleMunroCompletions);

        // Act
        await profileState.getProfileMunroCompletions();

        // Assert
        expect(profileState.munroCompletions, sampleMunroCompletions);
        verify(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123')).called(1);
        verifyNever(mockLogger.error(any, stackTrace: anyNamed('stackTrace')));
      });

      test('should handle error during munro completions loading', () async {
        // Arrange
        when(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123'))
            .thenThrow(Exception('Network error'));

        // Act
        await profileState.getProfileMunroCompletions();

        // Assert
        expect(profileState.error.message, 'There was an issue loading the munros. Please try again.');
        verify(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123')).called(1);
        verify(mockLogger.error(any, stackTrace: anyNamed('stackTrace'))).called(greaterThanOrEqualTo(1));
      });
    });

    group('Setters and Utility Methods', () {
      test('setStatus should update status and notify listeners', () {
        bool notified = false;
        profileState.addListener(() => notified = true);

        profileState.setStatus = ProfileStatus.loading;

        expect(profileState.status, ProfileStatus.loading);
        expect(notified, true);
      });

      test('setError should update error and status', () {
        final error = Error(code: 'test', message: 'test error');
        profileState.setError = error;

        expect(profileState.status, ProfileStatus.error);
        expect(profileState.error, error);
      });

      test('removePost should remove post from list', () async {
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).thenAnswer((_) async => sampleMunroPictures);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);

        await profileState.loadProfileFromUserId(userId: 'user123');

        await profileState.getProfilePosts();

        final postToRemove = samplePosts.first;
        profileState.removePost(postToRemove);

        expect(profileState.posts, hasLength(1));
        expect(profileState.posts.contains(postToRemove), false);
      });

      test('removePost should not affect list if post not found', () async {
        // Set up posts first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        await profileState.loadProfileFromUserId(userId: 'user123');

        final nonExistentPost = Post(
          uid: 'nonexistent',
          authorId: 'user123',
          authorDisplayName: 'john_doe',
          authorProfilePictureURL: 'https://example.com/profile.jpg',
          dateTimeCreated: DateTime(2023, 1, 1),
          title: 'Non-existent Munro',
          description: 'This post does not exist',
          imageUrlsMap: {},
          includedMunroIds: [999],
          likes: 0,
          privacy: Privacy.public,
        );

        profileState.removePost(nonExistentPost);

        expect(profileState.posts, hasLength(2));
      });

      test('updatePost should update existing post', () async {
        // Set up posts first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);

        await profileState.loadProfileFromUserId(userId: 'user123');

        final updatedPost = Post(
          uid: samplePosts.first.uid,
          authorId: samplePosts.first.authorId,
          authorDisplayName: samplePosts.first.authorDisplayName,
          authorProfilePictureURL: samplePosts.first.authorProfilePictureURL,
          dateTimeCreated: samplePosts.first.dateTimeCreated,
          title: samplePosts.first.title,
          description: 'Updated description',
          imageUrlsMap: samplePosts.first.imageUrlsMap,
          includedMunroIds: samplePosts.first.includedMunroIds,
          likes: 20,
          privacy: samplePosts.first.privacy,
        );

        profileState.updatePost(updatedPost);

        expect(profileState.posts.first.description, 'Updated description');
        expect(profileState.posts.first.likes, 20);
      });

      test('updatePost should not affect list if post not found', () async {
        // Set up posts first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).thenAnswer((_) async => sampleMunroPictures);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);

        await profileState.loadProfileFromUserId(userId: 'user123');

        final nonExistentPost = Post(
          uid: 'nonexistent',
          authorId: 'user123',
          authorDisplayName: 'john_doe',
          authorProfilePictureURL: 'https://example.com/profile.jpg',
          dateTimeCreated: DateTime(2023, 1, 1),
          title: 'Non-existent Munro',
          description: 'This post does not exist',
          imageUrlsMap: {},
          includedMunroIds: [999],
          likes: 0,
          privacy: Privacy.public,
        );

        profileState.updatePost(nonExistentPost);

        // Original posts should remain unchanged
        expect(profileState.posts, hasLength(2));
        expect(profileState.posts.first.description, 'Amazing climb today!');
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners when loading profile', () async {
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).thenAnswer((_) async => sampleMunroPictures);

        bool notified = false;
        profileState.addListener(() => notified = true);

        await profileState.loadProfileFromUserId(userId: 'user123');

        expect(notified, true);
      });

      test('should notify listeners when loading munro pictures', () async {
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 18,
        )).thenAnswer((_) async => sampleMunroPictures);

        bool notified = false;
        profileState.addListener(() => notified = true);

        await profileState.getMunroPictures(profileId: 'user123');

        expect(notified, true);
      });

      test('should notify listeners when removing posts', () async {
        // Set up posts first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        await profileState.loadProfileFromUserId(userId: 'user123');

        bool notified = false;
        profileState.addListener(() => notified = true);

        profileState.removePost(samplePosts.first);

        expect(notified, true);
      });

      test('should notify listeners when updating posts', () async {
        // Set up posts first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        await profileState.loadProfileFromUserId(userId: 'user123');

        bool notified = false;
        profileState.addListener(() => notified = true);

        final updatedPost = Post(
          uid: samplePosts.first.uid,
          authorId: samplePosts.first.authorId,
          authorDisplayName: samplePosts.first.authorDisplayName,
          authorProfilePictureURL: samplePosts.first.authorProfilePictureURL,
          dateTimeCreated: samplePosts.first.dateTimeCreated,
          title: samplePosts.first.title,
          description: samplePosts.first.description,
          imageUrlsMap: samplePosts.first.imageUrlsMap,
          includedMunroIds: samplePosts.first.includedMunroIds,
          likes: 100,
          privacy: samplePosts.first.privacy,
        );
        profileState.updatePost(updatedPost);

        expect(notified, true);
      });

      test('should notify listeners when getting munro completions', () async {
        when(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123'))
            .thenAnswer((_) async => sampleMunroCompletions);

        // Set up profile first
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        await profileState.loadProfileFromUserId(userId: 'user123');

        bool notified = false;
        profileState.addListener(() => notified = true);

        await profileState.getProfileMunroCompletions();

        expect(notified, true);
      });
    });

    group('Edge Cases', () {
      test('should handle null profile in getMunroPictures calls', () async {
        // Arrange - No profile loaded
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        expect(profileState.photoStatus, ProfilePhotoStatus.loaded);
        expect(profileState.profilePhotos, sampleMunroPictures);
      });

      test('should handle empty posts list', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => []);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);

        // Act
        await profileState.loadProfileFromUserId(userId: 'user123');

        // Assert
        expect(profileState.posts, isEmpty);
        expect(profileState.status, ProfileStatus.loaded);
      });

      test('should handle empty munro pictures list', () async {
        // Arrange
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => []);

        // Act
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        expect(profileState.profilePhotos, isEmpty);
        expect(profileState.photoStatus, ProfilePhotoStatus.loaded);
      });

      test('should handle empty munro completions list', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockMunroCompletionsRepository.getUserMunroCompletions(userId: 'user123')).thenAnswer((_) async => []);
        await profileState.loadProfileFromUserId(userId: 'user123');

        // Act
        await profileState.getProfileMunroCompletions();

        // Assert
        expect(profileState.munroCompletions, isEmpty);
      });

      test('should handle multiple consecutive calls gracefully', () async {
        // Arrange
        when(mockProfileRepository.getProfileFromUserId(userId: 'user123')).thenAnswer((_) async => sampleProfile);
        when(mockUserState.currentUser).thenReturn(sampleCurrentUser);
        when(mockPostsRepository.readPostsFromUserId(userId: 'user123')).thenAnswer((_) async => samplePosts);
        when(mockMunroPicturesRepository.readProfilePictures(
          profileId: 'user123',
          excludedAuthorIds: [],
          offset: 0,
          count: 4,
        )).thenAnswer((_) async => sampleMunroPictures);

        // Act - Make multiple calls
        await profileState.loadProfileFromUserId(userId: 'user123');
        await profileState.loadProfileFromUserId(userId: 'user123');
        await profileState.getMunroPictures(profileId: 'user123');
        await profileState.getMunroPictures(profileId: 'user123');

        // Assert
        expect(profileState.status, ProfileStatus.loaded);
        expect(profileState.photoStatus, ProfilePhotoStatus.loaded);
        // Should be called multiple times for each method call
        verify(mockProfileRepository.getProfileFromUserId(userId: 'user123')).called(2);
      });
    });
  });
}
