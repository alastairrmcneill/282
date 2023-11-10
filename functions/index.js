/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const { onDocumentCreated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const functions = require('firebase-functions/v1');

const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

// exports.onFollowUser = onDocumentCreated("followingRelationships/{relationshipId}", (event) => {

//  });


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