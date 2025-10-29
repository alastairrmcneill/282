const functions = require("firebase-functions/v1");
const { initializeApp, getApps } = require("firebase-admin/app");
const { getAuth } = require("firebase-admin/auth");

// Initialize Admin SDK once
if (getApps().length === 0) {
  initializeApp();
}

exports.setAllUserClaims = functions.https.onRequest(async (req, res) => {
  try {
    let nextPageToken;
    let processed = 0;
    let skipped = 0;
    let updated = 0;

    do {
      const listUsersResult = await getAuth().listUsers(1000, nextPageToken);
      nextPageToken = listUsersResult.pageToken;

      for (const user of listUsersResult.users) {
        // ✅ Check if custom claims already exist and match
        const currentClaims = user.customClaims || {};

        if (currentClaims.role === "authenticated") {
          skipped++;
          continue; // Skip users who already have the correct claim
        }

        try {
          await getAuth().setCustomUserClaims(user.uid, { ...currentClaims, role: "authenticated" });
          console.log(`✅ Updated claims for ${user.email || user.uid}`);
          updated++;

          // Prevent rate limits (5 requests/sec)
          await new Promise((r) => setTimeout(r, 200));
        } catch (err) {
          console.error(`❌ Failed for ${user.uid}`, err.message);
        }

        processed++;
      }
    } while (nextPageToken);

    const result = `✅ Done. Processed: ${processed}, Updated: ${updated}, Skipped: ${skipped}`;
    console.log(result);
    res.send(result);
  } catch (err) {
    console.error("❌ Error:", err);
    res.status(500).send(err.message);
  }
});
