const { beforeUserCreated, beforeUserSignedIn } = require("firebase-functions/v2/identity");

exports.beforecreated = beforeUserCreated(() => ({
  customClaims: { role: "authenticated" },
}));

exports.beforesignedin = beforeUserSignedIn(() => ({
  customClaims: { role: "authenticated" },
}));
