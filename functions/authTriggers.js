const { beforeUserCreated, beforeUserSignedIn } = require("firebase-functions/v2/identity");
const functionsV1 = require("firebase-functions/v1");
const { getAuth } = require("firebase-admin/auth");

exports.beforecreated = beforeUserCreated(() => ({
  customClaims: { role: "authenticated" },
}));

exports.beforesignedin = beforeUserSignedIn(() => ({
  customClaims: { role: "authenticated" },
}));

exports.onanonymoususercreated = functionsV1.auth.user().onCreate(async (user) => {
  if (user.providerData.length > 0) return;
  await getAuth().setCustomUserClaims(user.uid, { role: "authenticated" });
});
