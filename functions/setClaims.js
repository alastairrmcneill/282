const functions = require("firebase-functions/v1");
const { initializeApp, getApps } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

if (getApps().length === 0) {
  initializeApp();
}

exports.setAllUserClaims = functions.https.onRequest(async (req, res) => {
  let nextPageToken;
  do {
    const listUsersResult = await getAuth().listUsers(1000, nextPageToken);
    nextPageToken = listUsersResult.pageToken;
    await Promise.all(
      listUsersResult.users.map(async (user) => {
        try {
          await getAuth().setCustomUserClaims(user.uid, { role: "authenticated" });
          console.log(`✅ Set role for ${user.email || user.uid}`);
        } catch (err) {
          console.error(`❌ Failed for ${user.uid}`, err.message);
        }
      })
    );
  } while (nextPageToken);
  console.log("All users processed.");
});
