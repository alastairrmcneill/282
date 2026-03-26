const admin = require("firebase-admin");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

exports.beforecreated = require("./authTriggers").beforecreated;
exports.beforesignedin = require("./authTriggers").beforesignedin;
exports.imageProxy = require("./imageProxy").imageProxy;
