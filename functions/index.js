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
const base64 = require("base-64");
const fs = require("fs");

// Decode the Base64 encoded service account key
// const serviceAccount = JSON.parse(base64.decode(functions.config().service_account.key));

// Initialize Firebase Admin SDK
admin.initializeApp({
  // credential: admin.credential.cert(serviceAccount),
  // databaseURL: "https://prod-81998.firebaseio.com",
});

exports.onUserCreated = functions.firestore.document("users/{userId}").onCreate(async (snapshot, context) => {
  const userId = context.params.userId;

  try {
    // Create user feed
    console.log(`Creating feed for user: ${userId}`);
    const userFeedRef = admin.firestore().collection("feeds").doc(userId);
    await userFeedRef.set({});
    console.log(`Feed created for user: ${userId}`);

    // Get my profile
    console.log("Getting my profile");
    // const myProfileRef = admin.firestore().collection("users").doc("jw0V1hFySQfU2ST1ZtUW6wLAXIC3"); // Dev
    const myProfileRef = admin.firestore().collection("users").doc("v3qXEVdb6BYhB4wdyCeIfjSukbE2"); // Prod
    const myProfile = await myProfileRef.get();
    if (!myProfile.exists) {
      throw new Error("Profile document does not exist!");
    }
    console.log("Got my profile");

    // Create following relationships between the new user and me
    console.log("Create following relationships between the new user and me");
    const followingRelationshipsRef = admin.firestore().collection("followingRelationships");

    const userFollowingRelationshipRef = followingRelationshipsRef.doc();
    await userFollowingRelationshipRef.set({
      uid: userFollowingRelationshipRef.id,
      sourceId: userId,
      sourceDisplayName: snapshot.get("displayName"),
      sourceProfilePictureURL: snapshot.get("profilePictureURL"),
      targetId: myProfile.get("uid"),
      targetDisplayName: myProfile.get("displayName"),
      targetProfilePictureURL: myProfile.get("profilePictureURL"),
    });
    console.log("Following relationship created between the new user and me");

    await new Promise((resolve) => setTimeout(resolve, 1000));

    // Create following relationship between me and the new user
    console.log("Create following relationship between me and the new user");
    const userFollowedRelationshipRef = followingRelationshipsRef.doc();
    await userFollowedRelationshipRef.set({
      uid: userFollowedRelationshipRef.id,
      sourceId: myProfile.get("uid"),
      sourceDisplayName: myProfile.get("displayName"),
      sourceProfilePictureURL: myProfile.get("profilePictureURL"),
      targetId: userId,
      targetDisplayName: snapshot.get("displayName"),
      targetProfilePictureURL: snapshot.get("profilePictureURL"),
    });
    console.log("Following relationship created between me and the new user");

    console.log("User created successfully");
  } catch (error) {
    console.error("Error creating user: ", error);
  }
});

exports.onUserUpdated = functions.firestore.document("users/{userId}").onUpdate(async (snapshot, context) => {
  const userId = context.params.userId;
  const before = snapshot.before.data();
  const after = snapshot.after.data();

  if (before.displayName === after.displayName && before.profilePictureURL === after.profilePictureURL) {
    console.log("No changes to user");
    return;
  }

  // Update comments
  // TODO: Update comments where user is author

  // Update following relationship where user is source
  console.log("Update following relationships user is source");
  const followingRelationshipsRef = admin.firestore().collection("followingRelationships");
  const userFollowingRelationshipRef = followingRelationshipsRef.where("sourceId", "==", userId);
  const userFollowingRelationshipSnapshot = await userFollowingRelationshipRef.get();

  userFollowingRelationshipSnapshot.forEach((doc) => {
    console.log(`Updating following relationship: ${doc.id}`);
    doc.ref.update({
      sourceDisplayName: snapshot.after.get("displayName"),
      sourceProfilePictureURL: snapshot.after.get("profilePictureURL"),
    });
  });
  console.log("Following relationships updated");

  // Update following relationship where user is target
  console.log("Update following relationship where user is target");
  const userFollowedRelationshipRef = followingRelationshipsRef.where("targetId", "==", userId);
  const userFollowedRelationshipSnapshot = await userFollowedRelationshipRef.get();

  userFollowedRelationshipSnapshot.forEach((doc) => {
    console.log(`Updating following relationship: ${doc.id}`);
    doc.ref.update({
      targetDisplayName: snapshot.after.get("displayName"),
      targetProfilePictureURL: snapshot.after.get("profilePictureURL"),
    });
  });
  console.log("Following relationship where user is target updated ");

  // Update posts
  console.log("Update posts");
  const postsRef = admin.firestore().collection("posts").where("authorId", "==", userId);
  const postsSnapshot = await postsRef.get();

  postsSnapshot.forEach((doc) => {
    console.log(`Updating post: ${doc.id}`);
    doc.ref.update({
      authorDisplayName: snapshot.after.get("displayName"),
      authorProfilePictureURL: snapshot.after.get("profilePictureURL"),
    });
  });
  console.log("Posts updated");

  console.log("User updated successfully");
});

exports.onUserDeleted = functions.firestore.document("users/{userId}").onDelete(async (snapshot, context) => {
  const userId = context.params.userId;

  // Delete user comments
  console.log(`Deleting comments for user: ${userId}`);
  const userCommentsRef = admin.firestore().collectionGroup("postComments").where("authorId", "==", userId);
  const userCommentsSnapshot = await userCommentsRef.get();

  userCommentsSnapshot.forEach((doc) => {
    console.log(`Deleting comment: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Comments deleted for user");

  // Delete user feed
  console.log(`Deleting feed for user: ${userId}`);
  const userFeedRef = admin.firestore().collection("feeds").doc(userId);
  userFeedRef.delete();
  console.log(`Feed deleted for user: ${userId}`);

  // Delete following relationships where user is source
  console.log("Delete following relationships where user is source");
  const followingRelationshipsRef = admin.firestore().collection("followingRelationships");
  const userFollowingRelationshipRef = followingRelationshipsRef.where("sourceId", "==", userId);
  const userFollowingRelationshipSnapshot = await userFollowingRelationshipRef.get();

  userFollowingRelationshipSnapshot.forEach((doc) => {
    console.log(`Deleting following relationship: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Following relationships where user is source deleted");

  // Delete following relationships where user is target
  console.log("Delete following relationships where user is target");
  const userFollowedRelationshipRef = followingRelationshipsRef.where("targetId", "==", userId);
  const userFollowedRelationshipSnapshot = await userFollowedRelationshipRef.get();

  userFollowedRelationshipSnapshot.forEach((doc) => {
    console.log(`Deleting following relationship: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Following relationships where user is target deleted");

  // Delete likes
  console.log("Delete likes");
  const likesRef = admin.firestore().collection("likes").where("userId", "==", userId);
  const likesSnapshot = await likesRef.get();

  likesSnapshot.forEach((doc) => {
    console.log(`Deleting like: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Likes deleted");

  // Delete notifications
  console.log("Delete notifications");
  const notificationsTargetRef = admin.firestore().collection("notifications").where("targetId", "==", userId);
  const notificationsTargetSnapshot = await notificationsTargetRef.get();

  notificationsTargetSnapshot.forEach((doc) => {
    console.log(`Deleting notification: ${doc.id}`);
    doc.ref.delete();
  });

  const notificationsSourceRef = admin.firestore().collection("notifications").where("sourceId", "==", userId);
  const notificationsSourceSnapshot = await notificationsSourceRef.get();

  notificationsSourceSnapshot.forEach((doc) => {
    console.log(`Deleting notification: ${doc.id}`);
    doc.ref.delete();
  });

  console.log("Notifications deleted");

  // Delete posts
  console.log("Delete posts");
  const postsRef = admin.firestore().collection("posts").where("authorId", "==", userId);
  const postsSnapshot = await postsRef.get();

  postsSnapshot.forEach((doc) => {
    console.log(`Deleting post: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Posts deleted");

  // Delete reviews
  console.log("Delete reviews");
  const reviewsRef = admin.firestore().collection("reviews").where("authorId", "==", userId);
  const reviewsSnapshot = await reviewsRef.get();

  reviewsSnapshot.forEach((doc) => {
    console.log(`Deleting review: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Reviews deleted");

  // Delete saved lists
  console.log("Delete saved lists");
  const savedListsRef = admin.firestore().collection("savedLists").where("userId", "==", userId);
  const savedListsSnapshot = await savedListsRef.get();

  savedListsSnapshot.forEach((doc) => {
    console.log(`Deleting saved list: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Saved lists deleted");

  // Delete Munro pictures
  console.log("Delete Munro pictures");
  const munroPicturesRef = admin.firestore().collection("munroPictures").where("authorId", "==", userId);
  const munroPicturesSnapshot = await munroPicturesRef.get();

  munroPicturesSnapshot.forEach((doc) => {
    console.log(`Deleting munro picture: ${doc.id}`);
    doc.ref.delete();
  });
  console.log("Munro pictures deleted");

  console.log("User deleted successfully");
});

exports.onFollowUser = functions.firestore
  .document("followingRelationships/{relationshipId}")
  .onCreate(async (snapshot, context) => {
    const relationshipId = context.params.uid;

    // if searchName doesn't exist then set it as lowercase displayName
    if (snapshot.get("targetSearchName") === undefined) {
      snapshot.ref.update({ targetSearchName: snapshot.get("targetDisplayName").toLowerCase() });
    }

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
        if (doc.get("privacy") === "private") return;
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
  const privacy = snapshot.get("privacy");

  // Upload photos first
  console.log("Creating munro pictures");
  const munroPicturesRef = admin.firestore().collection("munroPictures");
  const imageUrlsMap = snapshot.get("imageUrlsMap");
  const postDate = snapshot.get("dateTime");

  console.log("Map: ", imageUrlsMap);
  for (var key in imageUrlsMap) {
    console.log("Key: ", key);
    console.log("Value: ", imageUrlsMap[key]);
    for (var url of imageUrlsMap[key]) {
      console.log("URL: ", url);
      const munroPictureRef = munroPicturesRef.doc();
      await munroPictureRef.set({
        id: munroPictureRef.id,
        postId: postId,
        munroId: key,
        imageUrl: url,
        dateTime: postDate,
        authorId: authorId,
        privacy: privacy,
      });
    }
  }

  console.log("Munro pictures created successfully");

  // If private then don't carry on
  if (privacy === "private") {
    console.log("Post is private. Not adding to feeds");
    return;
  }

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

  console.log("Post added to feeds successfully");

  // If friends only then don't add to global feed
  if (privacy === "friends") {
    console.log("Post is friends only. Not adding to global feed");
    return;
  }

  // Add to global feed
  const globalFeedRef = admin.firestore().collection("globalFeed").doc(postId);
  await globalFeedRef.set(snapshot.data());
  console.log("Post added to global feed successfully");
});

exports.onPostUpdated = functions.firestore.document("/posts/{postId}").onUpdate(async (snapshot, context) => {
  const postId = context.params.postId;

  // Get author id.
  const authorId = snapshot.after.get("authorId");

  // Update post data in each follower's feed.
  const updatedPostData = snapshot.after.data();

  const privacy = snapshot.after.get("privacy");

  // Update munro pictures
  console.log("Updating munro pictures");

  // Delete old munro pictures
  const munroPicturesRef = admin.firestore().collection("munroPictures");
  const munroPicturesSnapshot = await munroPicturesRef.where("postId", "==", postId).get();

  for (var doc of munroPicturesSnapshot.docs) {
    console.log(`Deleting munro picture: ${doc.id}`);
    await doc.ref.delete();
  }

  // Create new munro pictures
  console.log("Creating munro pictures");
  const imageUrlsMap = snapshot.after.get("imageUrlsMap");
  const postDate = snapshot.after.get("dateTime");

  console.log("Map: ", imageUrlsMap);
  for (var key in imageUrlsMap) {
    console.log("Key: ", key);
    console.log("Value: ", imageUrlsMap[key]);
    for (var url of imageUrlsMap[key]) {
      console.log("URL: ", url);
      const munroPictureRef = munroPicturesRef.doc();
      await munroPictureRef.set({
        id: munroPictureRef.id,
        postId: postId,
        munroId: key,
        imageUrl: url,
        dateTime: postDate,
        authorId: authorId,
        privacy: privacy,
      });
    }
  }

  console.log("Munro pictures created successfully");

  if (privacy === "private") {
    console.log("Post is private. Not updating feeds");
    return;
  }

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
    } else {
      postDoc.ref.set(updatedPostData);
    }
  }

  console.log("Post updated in feeds successfully");

  // Update post in global feed
  if (privacy === "friends") {
    console.log("Post is friends only. Not updating global feed");
    return;
  }

  console.log("Updating post in global feed");
  const globalFeedRef = admin.firestore().collection("globalFeed").doc(postId);
  const globalPostDoc = await globalFeedRef.get();
  if (globalPostDoc.exists) {
    globalPostDoc.ref.update(updatedPostData);
  } else {
    globalPostDoc.ref.set(updatedPostData);
  }

  console.log("Post updated in global feed successfully");
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

  // Delete post from global feed
  console.log("Deleting post from global feed");
  const globalFeedRef = admin.firestore().collection("globalFeed").doc(postId);
  const globalPostDoc = await globalFeedRef.get();
  if (globalPostDoc.exists) {
    globalPostDoc.ref.delete();
  }

  console.log("Post deleted from global feed successfully");

  // Delete munro pictures
  console.log("Deleting munro pictures");
  const munroPicturesRef = admin.firestore().collection("munroPictures");
  const munroPicturesSnapshot = await munroPicturesRef.where("postId", "==", postId).get();

  munroPicturesSnapshot.forEach((doc) => {
    console.log(`Deleting munro picture: ${doc.id}`);
    doc.ref.delete();
  });

  console.log("Munro pictures deleted successfully");
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
    const postId = context.params.postId;
    const postRef = admin.firestore().collection("posts").doc(postId);
    const postDoc = await postRef.get();

    const sourceId = snapshot.get("authorId");
    const sourceProfilePictureURL = snapshot.get("authorProfilePictureURL");
    const sourceDisplayName = snapshot.get("authorDisplayName");

    // Update the list of commenters
    const postCommenterIds = postDoc.get("commenterIds") || [];
    if (!postCommenterIds.includes(sourceId)) {
      postCommenterIds.push(sourceId);
      await postRef.update({ commenterIds: postCommenterIds });
    }

    // Send notification to all commenters except the one who made the comment
    const targetIds = postCommenterIds.filter((id) => id !== sourceId);

    const batch = admin.firestore().batch();

    targetIds.forEach((targetId) => {
      const notificationRef = admin.firestore().collection("notifications").doc();
      batch.set(notificationRef, {
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

    // Commit the batch
    await batch.commit();
  });

exports.onNotificationCreated = functions.firestore
  .document("/notifications/{notificationId}")
  .onCreate(async (snapshot, context) => {
    console.log("Notification Created");
    console.log(`Service Account: ${serviceAccount.private_key}`);

    const targetId = snapshot.get("targetId");

    console.log(`TargetId: ${targetId}`);
    const userRef = admin.firestore().collection("users").doc(targetId);
    const userDoc = await userRef.get();

    console.log(`UserDoc retrieved. User: ${userDoc.id}`);

    const fcmToken = userDoc.get("fcmToken");
    console.log(`fcmToken: ${fcmToken}`);

    if (fcmToken == null || fcmToken == undefined || fcmToken == "") return;

    const sourceDisplayName = snapshot.get("sourceDisplayName");
    const type = snapshot.get("type");
    let notificationText = "";
    if (type == "like") {
      notificationText = " liked your post.";
    } else if (type == "comment") {
      notificationText = " commented on a post you follow.";
    } else if (type == "follow") {
      notificationText = " followed you.";
    }

    console.log(`Notification Text: ${notificationText}`);

    // Create the notification message
    const message = {
      notification: {
        title: `${sourceDisplayName}${notificationText}`,
      },
      data: {
        type: type,
      },
      token: fcmToken, // User's FCM token
    };

    console.log("Sending notification");
    admin.messaging().send(message);
    console.log("Notification sent");
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
  try {
    res.send("Migration completed successfully");
  } catch (error) {
    console.error("Error in migration: ", error);
    res.status(500).send("Failed to complete migration");
  }
});

exports.setMunroIdToString = functions.https.onRequest(async (req, res) => {
  try {
    // Update users
    const usersRef = admin.firestore().collection("users");
    const usersSnapshot = await usersRef.get();

    const usersBatch = admin.firestore().batch();

    console.log("Starting User Migration");
    usersSnapshot.docs.forEach((doc) => {
      const user = doc.data();
      console.log(`User: ${user.uid}`);
      if (user.personalMunroData && Array.isArray(user.personalMunroData)) {
        const personalMunroData = user.personalMunroData.map((munro) => {
          return { ...munro, id: munro.id.toString() };
        });
        usersBatch.update(doc.ref, { personalMunroData: personalMunroData });
      }
    });

    console.log("Finsihsed User Migration");

    await usersBatch.commit();

    res.send("Migration completed successfully");
  } catch (error) {
    console.error("Error in migration: ", error);
    res.status(500).send("Failed to complete migration");
  }
});

exports.addUserAchievementsIfDontExist = functions.https.onRequest(async (req, res) => {
  try {
    // Update users
    const usersRef = admin.firestore().collection("users");
    const usersSnapshot = await usersRef.get();

    const achievementsRef = admin.firestore().collection("achievements");
    const achievementsSnapshot = await achievementsRef.get();

    const usersBatch = admin.firestore().batch();

    console.log("Starting User Migration");
    usersSnapshot.docs.forEach((userDoc) => {
      const userData = userDoc.data();
      console.log(`User: ${userData.uid}`);
      if (userData.achievements && !Object.keys(userData.achievements).length) {
        console.log("Achievements map is empty");
        let achievementData = {};

        achievementsSnapshot.forEach((achievementDoc) => {
          console.log(`Achievement: ${achievementDoc.id}`);
          let achievementId = achievementDoc.id;
          achievementData = {
            ...achievementData,
            [achievementId]: {
              ...achievementDoc.data(),
              completed: false,
              progress: 0,
            },
          };
        });

        usersBatch.update(userDoc.ref, { achievements: achievementData });
      }
    });

    console.log("Finsihsed User Migration");

    await usersBatch.commit();

    res.send("Migration completed successfully");
  } catch (error) {
    console.error("Error in migration: ", error);
    res.status(500).send("Failed to complete migration");
  }
});

exports.scheduledRecalculateMunroRatings = functions.pubsub
  .schedule("every 5 minutes")
  .timeZone("Europe/London")
  .onRun(async () => {
    try {
      console.log("🚀 ~ scheduledRecalculateMunroRatings started");

      // Get meta data
      const db = admin.firestore();
      const metaRef = db.doc("system/ratingsSync");
      const metaSnap = await metaRef.get();

      const lastRatingsRun = metaSnap.exists ? metaSnap.data().lastRatingsRun : null;
      const lastRatingsRunDate = lastRatingsRun ? lastRatingsRun.toDate() : null;
      const now = admin.firestore.Timestamp.now();

      console.log("🚀 ~ lastRatingsRunDate:", lastRatingsRunDate);
      console.log("🚀 ~ now:", now);

      // Get reviews since last run
      let reviewsRef = db.collection("reviews");
      query = reviewsRef;

      if (lastRatingsRunDate) {
        query = reviewsRef.where("dateTime", ">", lastRatingsRunDate);
      }
      const reviewsSnapshot = await query.get();
      console.log("🚀 ~ reviewsSnapshot.size:", reviewsSnapshot.size);

      if (reviewsSnapshot.empty) return null;

      // Get current munro data
      const ratingsRef = db.doc("munroData/allRatings");
      const ratingsDoc = await ratingsRef.get();
      const ratingsData = ratingsDoc.exists ? ratingsDoc.data()?.ratings ?? {} : {};

      // Update current munro data
      reviewsSnapshot.forEach((doc) => {
        const data = doc.data();
        const munroId = data.munroId;
        const rating = data.rating;

        if (!munroId || typeof rating !== "number") return;

        // Initialize entry if missing
        if (!ratingsData[munroId]) {
          ratingsData[munroId] = {
            sumOfRatings: 0,
            numberOfRatings: 0,
          };
        }

        ratingsData[munroId].sumOfRatings += rating;
        ratingsData[munroId].numberOfRatings += 1;

        console.log(
          `🚀 ~ Updated ${munroId}: sum=${ratingsData[munroId].sumOfRatings}, count=${ratingsData[munroId].numberOfRatings}`
        );
      });

      // Save new munro data
      await ratingsRef.set({ ratings: ratingsData });

      // Save meta data
      await metaRef.set({ lastRatingsRun: now });

      console.log("🚀 ~ Set allRatings and lastRatingsRun successfully");
      console.log("🚀 ~ scheduledRecalculateMunroRatings finished successfully.");
      return null;
    } catch (error) {
      console.error("🚀 ~ Error in scheduledRecalculateMunroRatings:", error);
      return null;
    }
  });
