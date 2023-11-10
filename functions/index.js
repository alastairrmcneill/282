/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");

// const {
//     log,
//     info,
//     debug,
//     warn,
//     error,
//     write,
//   } = require("firebase-functions/logger");

// const functions = require('firebase-functions/v1');

// const logger = require("firebase-functions/logger");
// const admin = require("firebase-admin");





const functions = require('firebase-functions/v1');

const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();


exports.onFollowUser = functions.firestore
    .document("followingRelationships/{relationshipId}")
    .onCreate(async (snapshot, context) => {
        const relationshipId = context.params.uid;

        // Get IDs
        const sourceId = snapshot.get("sourceId");
        const targetId = snapshot.get("targetId");

        // increment followed user"s followers count.
        const followedUserRef = admin.firestore().collection("users").doc(targetId);
        const followedUserDoc = await followedUserRef.get();

        if (followedUserDoc.get("followersCount") !== undefined) {
            followedUserRef.update({
                followersCount: followedUserDoc.get("followersCount") + 1,
            });
        } else {
            followedUserRef.update({ followersCount: 1 });
        }

        // incremenet user"s following count.
        const userRef = admin.firestore().collection("users").doc(sourceId);
        const userDoc = await userRef.get();

        if (userDoc.get("followingCount") !== undefined) {
            userRef.update({ followingCount: userDoc.get("followingCount") + 1 });
        } else {
            userRef.update({ followingCount: 1 });
        }

        // Add followered user posts to user posts feed
        const followedUserPostsRef = admin
            .firestore()
            .collection('posts')
            .where("authorId", "==", targetId);

        const userFeedRef = admin
            .firestore()
            .collection('feeds')
            .doc(sourceId)
            .collection('userFeed')

        const followedUserPostsSnapshot = await followedUserPostsRef.get();

        followedUserPostsSnapshot.forEach((doc) => {
            if (doc.exists) {
                userFeedRef.doc(doc.id).set(doc.data());
            }
        });

    });

exports.onUnfollowUser = functions.firestore
    .document("followingRelationships/{relationshipId}")
    .onDelete(async (snapshot, context) => {
        const relationshipId = context.params.uid;

        // Get IDs
        const sourceId = snapshot.get("sourceId");
        const targetId = snapshot.get("targetId");


        // Decrement followed user"s followers count.
        const followedUserRef = admin.firestore().collection("users").doc(targetId);
        const followedUserDoc = await followedUserRef.get();

        if (followedUserDoc.get("followersCount") !== undefined) {
            followedUserRef.update({
                followersCount: followedUserDoc.get("followersCount") - 1,
            });
        } else {
            followedUserRef.update({ followersCount: 0 });
        }

        // Decrement user"s following count.
        const userRef = admin.firestore().collection("users").doc(sourceId);
        const userDoc = await userRef.get();

        if (userDoc.get("followingCount") !== undefined) {
            userRef.update({ followingCount: userDoc.get("followingCount") - 1 });
        } else {
            userRef.update({ followingCount: 0 });
        }

        // Remove unfollowered user posts from user posts feed
        const unfollowedUserFeedRef = admin
            .firestore()
            .collection('feeds')
            .doc(sourceId)
            .collection('userFeed')
            .where("authorId", "==", targetId);

        const unfollowedUserPostsSnapshot = await unfollowedUserFeedRef.get();

        unfollowedUserPostsSnapshot.forEach((doc) => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });

    });

exports.onPostCreated = functions.firestore
    .document("posts/{postId}")
    .onCreate(async (snapshot, context) => {
        const postId = context.params.postId;
        const authorId = snapshot.get("authorId");


        // Add new post to feeds of all followers.
        const userFollowerRelationshipsRef = admin
            .firestore()
            .collection('followingRelationships')
            .where('targetId', '==', authorId);


        const userFollowerRelationshipsSnapshot = await userFollowerRelationshipsRef.get();
        userFollowerRelationshipsSnapshot.forEach((doc) => {
            admin
                .firestore()
                .collection('feeds')
                .doc(doc.get("sourceId"))
                .collection('userFeed')
                .doc(postId)
                .set(snapshot.data());
        });
    });

exports.onPostUpdated = functions.firestore
    .document('/posts/{postId}')
    .onUpdate(async (snapshot, context) => {
        const postId = context.params.postId;

        // Get author id.
        const authorId = snapshot.after.get('authorId');


        // Update post data in each follower's feed.
        const updatedPostData = snapshot.after.data();

        // Add new post to feeds of all followers.
        const userFollowerRelationshipsRef = admin
            .firestore()
            .collection('followingRelationships')
            .where('targetId', '==', authorId);

        const userFollowersSnapshot = await userFollowerRelationshipsRef.get();

        for (let i = 0; i < userFollowersSnapshot.docs.length; i++) {
            let doc = userFollowersSnapshot.docs[i];
            const feedsRef = admin
                .firestore()
                .collection('feeds')
                .doc(doc.get('sourceId'))
                .collection('userFeed');
            const postDoc = await feedsRef.doc(postId).get();
            if (postDoc.exists) {
                postDoc.ref.update(updatedPostData);
            }
        }
    });

exports.onPostDeleted = functions.firestore
    .document('/posts/{postId}')
    .onDelete(async (snapshot, context) => {
        const postId = context.params.postId;

        // Get author id.
        const authorId = snapshot.get('authorId');

        // Add new post to feeds of all followers.
        const userFollowerRelationshipsRef = admin
            .firestore()
            .collection('followingRelationships')
            .where('targetId', '==', authorId);

        const userFollowersSnapshot = await userFollowerRelationshipsRef.get();

        logger.log(userFollowersSnapshot.docs.length);

        for (let i = 0; i < userFollowersSnapshot.docs.length; i++) {
            let doc = userFollowersSnapshot.docs[i];
            const feedsRef = admin
                .firestore()
                .collection('feeds')
                .doc(doc.get('sourceId'))
                .collection('userFeed');
            const postDoc = await feedsRef.doc(postId).get();
            if (postDoc.exists) {
                postDoc.ref.delete();
            }
        }

    });
