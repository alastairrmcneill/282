// functions/index.js
const functions = require("firebase-functions");
const fetch = require("node-fetch");

exports.imageProxy = functions.https.onRequest(async (req, res) => {
  try {
    // Grab the path after /images/
    const path = req.path.replace(/^\/+/, ""); // remove leading slash
    console.log("🎯 ~ imageProxy ~ path:", path);
    const storageUrl = `https://firebasestorage.googleapis.com/v0/b/prod-81998.appspot.com/o/${encodeURIComponent(
      path
    )}?alt=media`;

    console.log("🎯 ~ imageProxy ~ storageUrl:", storageUrl);

    const upstream = await fetch(storageUrl);
    if (!upstream.ok) return res.sendStatus(upstream.status);

    // Pass through headers
    res.set("Content-Type", upstream.headers.get("content-type") || "application/octet-stream");
    res.set("Cache-Control", "public, max-age=31536000, immutable");

    upstream.body.pipe(res);
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});
