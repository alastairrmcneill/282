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
const { FieldValue } = require('firebase-admin/firestore');

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

        // Create notification document
        // Get displayName and Profilepictureurl from source
        const sourceProfilePictureURL = snapshot.get("sourceProfilePictureURL");
        const sourceDisplayName = snapshot.get("sourceDisplayName");

        if (sourceId === targetId) return;

        const notificationRef = admin.firestore().collection("notifications").doc();
        notificationRef.set(
            {
                "id": notificationRef.id,
                "targetId": targetId,
                "sourceId": sourceId,
                "sourceDisplayName": sourceDisplayName,
                "sourceProfilePictureURL": sourceProfilePictureURL,
                "postId": null,
                "type": "follow",
                "dateTime": new Date(),
                "read": false,
            }
        );

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


exports.onLikeCreated = functions.firestore
    .document("/likes/{likeId}")
    .onCreate(async (snapshot, context) => {
        // Find postId
        const postId = snapshot.get("postId");

        // Increment likes
        const postRef = admin.firestore().collection("posts").doc(postId);
        postRef.update({ likes: FieldValue.increment(1) });

        // Create notification document
        // Get author id from post and set as target 
        const postDoc = await postRef.get();
        const targetId = postDoc.get("authorId");

        // Get displayName and Profilepictureurl from user
        const sourceId = snapshot.get("userId");
        const sourceProfilePictureURL = snapshot.get("userProfilePictureURL");
        const sourceDisplayName = snapshot.get("userDisplayName");

        // if target and source are the same then don't do anything
        if (sourceId === targetId) return;

        const notificationRef = admin.firestore().collection("notifications").doc();
        notificationRef.set(
            {
                "id": notificationRef.id,
                "targetId": targetId,
                "sourceId": sourceId,
                "sourceDisplayName": sourceDisplayName,
                "sourceProfilePictureURL": sourceProfilePictureURL,
                "postId": postId,
                "type": "like",
                "dateTime": new Date(),
                "read": false,
            }
        );


    });

exports.onLikeDeleted = functions.firestore
    .document("/likes/{likeId}")
    .onDelete(async (snapshot, context) => {
        // Find postId
        const postId = snapshot.get("postId");

        // Decrement likes
        const postRef = admin.firestore().collection("posts").doc(postId);
        postRef.update({ likes: FieldValue.increment(-1) });

    });

exports.onCommentCreated = functions.firestore
    .document("/comments/{postId}/postComments/{commentId}")
    .onCreate(async (snapshot, context) => {
        // Create notification document
        // Find postId
        const postId = context.params.postId;

        // Get author id from post and set as target 
        const postRef = admin.firestore().collection("posts").doc(postId);
        const postDoc = await postRef.get();
        const targetId = postDoc.get("authorId");

        // Get displayName and Profilepictureurl from comment
        const sourceId = snapshot.get("authorId");
        const sourceProfilePictureURL = snapshot.get("authorProfilePictureURL");
        const sourceDisplayName = snapshot.get("authorDisplayName");
        if (sourceId === targetId) return;

        const notificationRef = admin.firestore().collection("notifications").doc();
        notificationRef.set(
            {
                "id": notificationRef.id,
                "targetId": targetId,
                "sourceId": sourceId,
                "sourceDisplayName": sourceDisplayName,
                "sourceProfilePictureURL": sourceProfilePictureURL,
                "postId": postId,
                "type": "comment",
                "dateTime": new Date(),
                "read": false,
            }
        );


    });

exports.onNotificationCreated = functions.firestore
    .document("/notifications/{notificationId}")
    .onCreate(async (snapshot, context) => {
        const targetId = snapshot.get("targetId");

        const userRef = admin.firestore().collection("users").doc(targetId);
        const userDoc = await userRef.get();

        const fcmToken = userDoc.get("fcmToken");
        console.log(`fcmToken: ${fcmToken}`);

        if (fcmToken == null || fcmToken == undefined || fcmToken == "") return;

        const sourceDisplayName = snapshot.get("sourceDisplayName");
        const type = snapshot.get("type");
        let notificationText = '';
        if (type == "like") {
            notificationText = " liked your post.";
        } else if (type == "comment") {
            notificationText = " commented on your post.";
        } else if (type == "follow") {
            notificationText = " followed you.";
        }

        const payload = {
            notification: {
                title: `${sourceDisplayName}${notificationText}`,
            },
            data: {
                "type": type,
            }
        };
        const options = {
            priority: "high",
            timeToLive: 60 * 60 * 24,
        };

        admin.messaging().sendToDevice(fcmToken, payload, options);

    });