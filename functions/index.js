const { initializeApp, getApps } = require("firebase-admin/app");

if (!getApps().length) {
  initializeApp();
}

exports.beforecreated = require("./authTriggers").beforecreated;
exports.beforesignedin = require("./authTriggers").beforesignedin;
exports.imageProxy = require("./imageProxy").imageProxy;
