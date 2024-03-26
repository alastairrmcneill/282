import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostsDatabase {
  static final _db = FirebaseFirestore.instance;
  static final CollectionReference _postsRef = _db.collection('posts');
  static final CollectionReference _feedsRef = _db.collection('feeds');

  // Create Post
  static Future create(BuildContext context, {required Post post}) async {
    try {
      DocumentReference ref = _postsRef.doc();

      Post newPost = post.copyWith(uid: ref.id);

      await ref.set(newPost.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error creating your post.");
    }
  }

  // Update Post
  static Future update(BuildContext context, {required Post post}) async {
    try {
      DocumentReference ref = _postsRef.doc(post.uid);

      await ref.update(post.toJSON());
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error updating your post.");
    }
  }

  // Read post
  static Future<Post?> readPostFromUid(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _postsRef.doc(uid);
      DocumentSnapshot documentSnapshot = await ref.get();

      Map<String, Object?> data = documentSnapshot.data() as Map<String, Object?>;

      Post post = Post.fromJSON(data);

      return post;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your post.");
      return null;
    }
  }

  // Read posts
  static Future<List<Post>> readAllPost(BuildContext context) async {
    List<Post> posts = [];
    try {
      QuerySnapshot querySnapshot = await _postsRef.get();

      for (var doc in querySnapshot.docs) {
        Post post = Post.fromJSON(doc.data() as Map<String, dynamic>);

        posts.add(post);
      }

      return posts;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error fetching your post.");
      return posts;
    }
  }

  static Future<List<Post>> readPostsFromUserId(
    BuildContext context, {
    required String userId,
    required String? lastPostId,
  }) async {
    List<Post> posts = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastPostId == null) {
        // Load first bathc
        querySnapshot = await _postsRef
            .orderBy(PostFields.dateTime, descending: true)
            .where(PostFields.authorId, isEqualTo: userId)
            .limit(6)
            .get();
      } else {
        final lastPostDoc = await _postsRef.doc(lastPostId).get();

        if (!lastPostDoc.exists) return [];

        querySnapshot = await _postsRef
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPostDoc)
            .where(PostFields.authorId, isEqualTo: userId)
            .limit(6)
            .get();
      }
      for (var doc in querySnapshot.docs) {
        Post post = Post.fromJSON(doc.data() as Map<String, dynamic>);
        posts.add(post);
      }

      return posts;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an issue getting the posts.");
      return [];
    }
  }

  // Delete post
  static Future deletePostWithUID(BuildContext context, {required String uid}) async {
    try {
      DocumentReference ref = _postsRef.doc(uid);

      await ref.delete();
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error deleting your post");
    }
  }

  static Future getFeedFromUserId(
    BuildContext context, {
    required String userId,
    required lastPostId,
  }) async {
    List<Post> posts = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastPostId == null) {
        // Load first bathc
        querySnapshot = await _feedsRef
            .doc(userId)
            .collection('userFeed')
            .orderBy(PostFields.dateTime, descending: true)
            .limit(10)
            .get();
      } else {
        final lastPostDoc = await _postsRef.doc(lastPostId).get();

        if (!lastPostDoc.exists) return [];

        querySnapshot = await _feedsRef
            .doc(userId)
            .collection('userFeed')
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPostDoc)
            .limit(10)
            .get();
      }

      for (var doc in querySnapshot.docs) {
        Post post = Post.fromJSON(doc.data() as Map<String, dynamic>);

        posts.add(post);
      }

      return posts;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error getting the posts. Please try again.");
      return posts;
    }
  }

  static Future getPostsFromMunro(
    BuildContext context, {
    required String munroId,
    required String? lastPostId,
    int count = 20,
  }) async {
    List<Post> posts = [];
    QuerySnapshot querySnapshot;

    try {
      if (lastPostId == null) {
        // Load first batch
        querySnapshot = await _postsRef
            .where(PostFields.imageURLs, isNotEqualTo: [])
            .orderBy(PostFields.imageURLs)
            .orderBy(PostFields.dateTime, descending: true)
            .where(PostFields.includedMunroIds, arrayContains: munroId)
            .where(PostFields.public, isEqualTo: true)
            .limit(count)
            .get();
      } else {
        final lastPostDoc = await _postsRef.doc(lastPostId).get();

        if (!lastPostDoc.exists) return [];

        querySnapshot = await _postsRef
            .where(PostFields.imageURLs, isNotEqualTo: [])
            .orderBy(PostFields.imageURLs)
            .orderBy(PostFields.dateTime, descending: true)
            .startAfterDocument(lastPostDoc)
            .where(PostFields.includedMunroIds, arrayContains: munroId)
            .where(PostFields.public, isEqualTo: true)
            .limit(count)
            .get();
      }

      for (var doc in querySnapshot.docs) {
        Post post = Post.fromJSON(doc.data() as Map<String, dynamic>);
        posts.add(post);
      }

      return posts;
    } on FirebaseException catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: error.message ?? "There was an error getting the posts. Please try again.");
      return posts;
    }
  }
}
