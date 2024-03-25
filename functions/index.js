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

const functions = require("firebase-functions/v1");

const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const { FieldValue } = require("firebase-admin/firestore");
const { user } = require("firebase-functions/v1/auth");

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
    const followedUserPostsRef = admin.firestore().collection("posts").where("authorId", "==", targetId);

    const userFeedRef = admin.firestore().collection("feeds").doc(sourceId).collection("userFeed");

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
    notificationRef.set({
      id: notificationRef.id,
      targetId: targetId,
      sourceId: sourceId,
      sourceDisplayName: sourceDisplayName,
      sourceProfilePictureURL: sourceProfilePictureURL,
      postId: null,
      type: "follow",
      dateTime: new Date(),
      read: false,
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
      .collection("feeds")
      .doc(sourceId)
      .collection("userFeed")
      .where("authorId", "==", targetId);

    const unfollowedUserPostsSnapshot = await unfollowedUserFeedRef.get();

    unfollowedUserPostsSnapshot.forEach((doc) => {
      if (doc.exists) {
        doc.ref.delete();
      }
    });
  });

exports.onPostCreated = functions.firestore.document("posts/{postId}").onCreate(async (snapshot, context) => {
  const postId = context.params.postId;
  const authorId = snapshot.get("authorId");

  // Add new post to feeds of all followers.
  const userFollowerRelationshipsRef = admin
    .firestore()
    .collection("followingRelationships")
    .where("targetId", "==", authorId);

  // Add post to all followers feeds
  const userFollowerRelationshipsSnapshot = await userFollowerRelationshipsRef.get();
  console.log("Starting to add post to feeds");
  userFollowerRelationshipsSnapshot.forEach((doc) => {
    console.log(`Adding post to feed of ${doc.get("sourceId")}`);
    admin
      .firestore()
      .collection("feeds")
      .doc(doc.get("sourceId"))
      .collection("userFeed")
      .doc(postId)
      .set(snapshot.data());
  });

  // Add post to author's feed
  console.log(`Adding post to feed of ${authorId}`);
  admin.firestore().collection("feeds").doc(authorId).collection("userFeed").doc(postId).set(snapshot.data());

  console.log("Post added to feeds successfully");
});

exports.onPostUpdated = functions.firestore.document("/posts/{postId}").onUpdate(async (snapshot, context) => {
  const postId = context.params.postId;

  // Get author id.
  const authorId = snapshot.after.get("authorId");

  // Update post data in each follower's feed.
  const updatedPostData = snapshot.after.data();

  // Add new post to feeds of all followers.
  const userFollowerRelationshipsRef = admin
    .firestore()
    .collection("followingRelationships")
    .where("targetId", "==", authorId);

  const userFollowersSnapshot = await userFollowerRelationshipsRef.get();

  console.log("Starting to update post in feeds");
  for (let i = 0; i < userFollowersSnapshot.docs.length; i++) {
    console.log(`Updating post in feed of ${userFollowersSnapshot.docs[i].get("sourceId")}`);
    let doc = userFollowersSnapshot.docs[i];
    const feedsRef = admin.firestore().collection("feeds").doc(doc.get("sourceId")).collection("userFeed");
    const postDoc = await feedsRef.doc(postId).get();
    if (postDoc.exists) {
      postDoc.ref.update(updatedPostData);
    }
  }

  // Update post data in author's feed.
  console.log(`Updating post in feed of ${authorId}`);
  const authorFeedRef = admin.firestore().collection("feeds").doc(authorId).collection("userFeed");
  const authorPostDoc = await authorFeedRef.doc(postId).get();

  if (authorPostDoc.exists) {
    authorPostDoc.ref.update(updatedPostData);
  }

  console.log("Post updated in feeds successfully");
});

exports.onPostDeleted = functions.firestore.document("/posts/{postId}").onDelete(async (snapshot, context) => {
  const postId = context.params.postId;

  // Get author id.
  const authorId = snapshot.get("authorId");

  // Add new post to feeds of all followers.
  const userFollowerRelationshipsRef = admin
    .firestore()
    .collection("followingRelationships")
    .where("targetId", "==", authorId);

  const userFollowersSnapshot = await userFollowerRelationshipsRef.get();

  // Delete post from each follower's feed.
  console.log("Starting to delete post from feeds");

  for (let i = 0; i < userFollowersSnapshot.docs.length; i++) {
    console.log(`Deleting post from feed of ${userFollowersSnapshot.docs[i].get("sourceId")}`);
    let doc = userFollowersSnapshot.docs[i];
    const feedsRef = admin.firestore().collection("feeds").doc(doc.get("sourceId")).collection("userFeed");
    const postDoc = await feedsRef.doc(postId).get();
    if (postDoc.exists) {
      postDoc.ref.delete();
    }
  }

  // Update post data in author's feed.
  console.log(`Deleting post from feed of ${authorId}`);
  const authorFeedRef = admin.firestore().collection("feeds").doc(authorId).collection("userFeed");
  const authorPostDoc = await authorFeedRef.doc(postId).get();
  if (authorPostDoc.exists) {
    authorPostDoc.ref.delete();
  }

  console.log("Post deleted from feeds successfully");
});

exports.onLikeCreated = functions.firestore.document("/likes/{likeId}").onCreate(async (snapshot, context) => {
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
  notificationRef.set({
    id: notificationRef.id,
    targetId: targetId,
    sourceId: sourceId,
    sourceDisplayName: sourceDisplayName,
    sourceProfilePictureURL: sourceProfilePictureURL,
    postId: postId,
    type: "like",
    dateTime: new Date(),
    read: false,
  });
});

exports.onLikeDeleted = functions.firestore.document("/likes/{likeId}").onDelete(async (snapshot, context) => {
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
    notificationRef.set({
      id: notificationRef.id,
      targetId: targetId,
      sourceId: sourceId,
      sourceDisplayName: sourceDisplayName,
      sourceProfilePictureURL: sourceProfilePictureURL,
      postId: postId,
      type: "comment",
      dateTime: new Date(),
      read: false,
    });
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
    let notificationText = "";
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
        type: type,
      },
    };
    const options = {
      priority: "high",
      timeToLive: 60 * 60 * 24,
    };

    admin.messaging().sendToDevice(fcmToken, payload, options);
  });

exports.onReviewCreated = functions.firestore.document("/reviews/{reviewId}").onCreate(async (snapshot, context) => {
  const reviewId = context.params.reviewId;
  const munroId = snapshot.get("munroId");
  const newReview = snapshot.data();
  // Get munro doc
  const munroRef = admin.firestore().collection("munros").doc(`${munroId}`);
  const munroDoc = await munroRef.get();

  console.log(`Munro doc: ${munroDoc.data()}`);

  if (munroDoc.exists) {
    // If exists increment review count and rating
    console.log("Munro exists");
    const oldRating = munroDoc.data().averageRating;
    const oldCount = munroDoc.data().reviewCount;
    const newRating = (oldRating * oldCount + newReview.rating) / (oldCount + 1);

    munroRef.update({
      reviewCount: FieldValue.increment(1),
      averageRating: newRating,
    });
  } else {
    // If doesn't exist create munro doc and set review count and rating
    console.log("Munro doesn't exist");
    munroRef.set({
      id: munroId,
      reviewCount: 1,
      averageRating: snapshot.get("rating"),
    });
  }

  console.log(`Munro ${munroId} Updated`);
});

exports.onReviewUpdated = functions.firestore.document("/reviews/{reviewId}").onUpdate(async (snapshot, context) => {
  // Get old and new review
  const oldReview = snapshot.before.data();
  const newReview = snapshot.after.data();

  // Get munro doc
  const munroRef = admin.firestore().collection("munros").doc(oldReview.munroId);
  const munroDoc = await munroRef.get();

  console.log(`Munro doc: ${munroDoc.data()}`);
  if (munroDoc.exists) {
    console.log("Munro exists");
    // If it exists, update the average rating after this change
    const oldRating = munroDoc.data().averageRating;
    const oldCount = munroDoc.data().reviewCount;
    const newRating = (oldRating * oldCount - oldReview.rating + newReview.rating) / oldCount;

    munroRef.update({
      averageRating: newRating,
    });
  } else {
    console.log("Munro doesn't exist");
    // If it doesn't exist, create a new munro doc and set the average rating
    munroRef.set({
      id: oldReview.munroId,
      reviewCount: 1,
      averageRating: newReview.rating,
    });
  }

  // Update the munro doc
  console.log(`Munro ${oldReview.munroId} Updated`);
});

exports.onReviewDeleted = functions.firestore.document("/reviews/{reviewId}").onDelete(async (snapshot, context) => {
  // Get old review
  const oldReview = snapshot.data();

  // Get munro Doc
  const munroRef = admin.firestore().collection("munros").doc(oldReview.munroId);
  const munroDoc = await munroRef.get();

  console.log(`Munro doc: ${munroDoc.data()}`);

  // If it exists, update the average rating after this change
  if (munroDoc.exists) {
    console.log("Munro exists");
    const oldRating = munroDoc.data().averageRating;
    const oldCount = munroDoc.data().reviewCount;

    if (oldCount - 1 > 0) {
      const newRating = (oldRating * oldCount - oldReview.rating) / (oldCount - 1);

      munroRef.update({
        reviewCount: FieldValue.increment(-1),
        averageRating: newRating,
      });
    } else {
      munroRef.delete();
    }
  }
  console.log(`Munro ${oldReview.munroId} Updated`);
});

exports.onAchievementCreated = functions.firestore
  .document("/achievements/{achievementId}")
  .onCreate(async (snapshot, context) => {
    console.log("Achievement Created");
    const achievementId = context.params.achievementId;
    const achievement = snapshot.data();

    const usersRef = admin.firestore().collection("users");
    const usersSnapshot = await usersRef.get();

    let batch = admin.firestore().batch();

    usersSnapshot.forEach((userDoc) => {
      console.log(`User: ${userDoc.id}`);

      let userRef = usersRef.doc(userDoc.id);
      let achievementData = {
        [`achievements.${context.params.achievementId}`]: {
          ...snapshot.data(),
          completed: false,
          progress: 0,
        },
      };
      batch.update(userRef, achievementData, { merge: true });
    });

    await batch.commit();

    console.log("Achievement added to all users successfully");
  });

exports.onAchievementUpdated = functions.firestore
  .document("/achievements/{achievementId}")
  .onUpdate(async (snapshot, context) => {
    console.log("Achievement Updated");
    const achievementId = context.params.achievementId;
    const achievement = snapshot.after.data();

    const usersRef = admin.firestore().collection("users");
    const usersSnapshot = await usersRef.get();

    let batch = admin.firestore().batch();

    usersSnapshot.forEach((userDoc) => {
      console.log(`User: ${userDoc.id}`);
      let userRef = usersRef.doc(userDoc.id);

      // Fetch the current user's achievement data
      const userAchievementData = userDoc.data().achievements[achievementId];

      if (!userAchievementData || userAchievementData.completed === undefined) {
        userCompleted = false;
      } else {
        userCompleted = userAchievementData.completed;
      }

      if (!userAchievementData || userAchievementData.progress === undefined) {
        userProgress = 0;
      } else {
        userProgress = userAchievementData.progress;
      }

      // Merge the current user's achievement data with the updated achievement data
      const mergedAchievementData = {
        ...achievement,
        completed: userCompleted,
        progress: userProgress,
      };

      let achievementData = {
        [`achievements.${achievementId}`]: mergedAchievementData,
      };

      batch.update(userRef, achievementData, { merge: true });
    });

    await batch.commit();

    console.log("Achievement updated for all users successfully");
  });

exports.onAchievementDeleted = functions.firestore
  .document("/achievements/{achievementId}")
  .onDelete(async (snapshot, context) => {
    console.log("Achievement Deleted");
    const achievementId = context.params.achievementId;

    const usersRef = admin.firestore().collection("users");
    const usersSnapshot = await usersRef.get();

    let batch = admin.firestore().batch();

    usersSnapshot.forEach((userDoc) => {
      console.log(`User: ${userDoc.id}`);

      let userRef = usersRef.doc(userDoc.id);
      let achievementData = {
        [`achievements.${context.params.achievementId}`]: FieldValue.delete(),
      };
      batch.update(userRef, achievementData, { merge: true });
    });

    await batch.commit();

    console.log("Achievement deleted for all users successfully");
  });

exports.databaseMigration = functions.https.onRequest(async (req, res) => {
  // Update users
  const usersRef = admin.firestore().collection("users");
  const usersSnapshot = await usersRef.get();

  const usersBatch = admin.firestore().batch();

  console.log("Starting User Migration");

  usersSnapshot.forEach((doc) => {
    console.log(`User: ${doc.id}`);

    if (!doc.data().hasOwnProperty("munroChallenges")) {
      let docRef = usersRef.doc(doc.id);
      usersBatch.set(docRef, { munroChallenges: [] }, { merge: true });
    }
  });

  console.log("Finsihsed User Migration");

  await usersBatch.commit();

  res.send("Migration completed successfully");
});
