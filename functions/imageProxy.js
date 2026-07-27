const { onRequest } = require("firebase-functions/v2/https");
const { getStorage } = require("firebase-admin/storage");
const sharp = require("sharp");

const MAX_WIDTH = 1920; // hard ceiling regardless of what's requested
const bucketName = "prod-81998.appspot.com";

exports.imageProxy = onRequest({ memory: "512MiB", timeoutSeconds: 30 }, async (req, res) => {
  console.log("🎯 ~ exports.imageProxy=functions.runWith ~ res:", res);
  console.log("🎯 ~ exports.imageProxy=functions.runWith ~ req:", req);

  try {
    const path = decodeURIComponent(req.path.replace(/^\/+/, ""));
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ path:", path);
    const width = req.query.width ? Math.min(parseInt(req.query.width), MAX_WIDTH) : null;
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ width:", width);
    const quality = req.query.quality ? parseInt(req.query.quality) : 80;
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ quality:", quality);

    const bucket = getStorage().bucket(bucketName);
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ bucket:", bucket);
    const originalFile = bucket.file(path);
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ originalFile:", originalFile);

    // Serve a cached resized variant if we've already made one
    const cachePath = width ? `cache/${path}_w${width}_q${quality}.jpg` : null;
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ cachePath:", cachePath);

    if (cachePath) {
      console.log("🎯 ~ exports.imageProxy if (cachePath) = true");
      const cacheFile = bucket.file(cachePath);
      console.log("🎯 ~ exports.imageProxy=functions.runWith ~ cacheFile:", cacheFile);
      const [cacheExists] = await cacheFile.exists();
      console.log("🎯 ~ exports.imageProxy=functions.runWith ~ cacheExists:", cacheExists);
      if (cacheExists) {
        console.log("🎯 ~ exports.imageProxy if (cacheExists) = true");

        res.set("Content-Type", "image/jpeg");
        res.set("Cache-Control", "public, max-age=31536000, immutable");
        cacheFile.createReadStream().pipe(res);
        return;
      }
    }
    console.log("🎯 ~ exports.imageProxy if (cachePath) = false");

    const [exists] = await originalFile.exists();
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ exists:", exists);
    if (!exists) return res.sendStatus(404);

    const [buffer] = await originalFile.download();
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ buffer:", buffer);

    if (!width || width == MAX_WIDTH) {
      // No resize requested — behave exactly as before
      console.log("🎯 ~ exports.imageProxy if (!width || width == MAX_WIDTH) = true");
      res.set("Content-Type", "image/jpeg");
      res.set("Cache-Control", "public, max-age=31536000, immutable");
      res.send(buffer);
      return;
    }

    const resized = await sharp(buffer).resize({ width, height: width, fit: "inside", withoutEnlargement: true }).jpeg({ quality }).toBuffer();
    console.log("🎯 ~ exports.imageProxy=functions.runWith ~ resized:", resized);

    // Write-through cache — don't block the response on it
    bucket.file(cachePath).save(resized, { contentType: "image/jpeg", resumable: false }).catch(console.error);

    res.set("Content-Type", "image/jpeg");
    res.set("Cache-Control", "public, max-age=31536000, immutable");
    res.send(resized);
  } catch (err) {
    console.error(err);
    res.sendStatus(500);
  }
});
