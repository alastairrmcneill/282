const { initializeApp, getApps } = require("firebase-admin/app");

if (!getApps().length) {
  initializeApp();
}

exports.beforecreated = require("./authTriggers").beforecreated;
exports.beforesignedin = require("./authTriggers").beforesignedin;
exports.onanonymoususercreated = require("./authTriggers").onanonymoususercreated;
exports.imageProxy = require("./imageProxy").imageProxy;
