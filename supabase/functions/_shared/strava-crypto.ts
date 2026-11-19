// AES-256-GCM encryption for Strava tokens at rest.
// STRAVA_TOKEN_ENCRYPTION_KEY must be 32 random bytes, base64 encoded:
//   openssl rand -base64 32

const PREFIX = "v1:";
const IV_BYTES = 12;

let cachedKey: Promise<CryptoKey> | null = null;

function base64ToBytes(b64: string): Uint8Array<ArrayBuffer> {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

function bytesToBase64(bytes: Uint8Array): string {
  let bin = "";
  for (const b of bytes) bin += String.fromCharCode(b);
  return btoa(bin);
}

function getKey(): Promise<CryptoKey> {
  if (!cachedKey) {
    const raw = Deno.env.get("STRAVA_TOKEN_ENCRYPTION_KEY");
    if (!raw) throw new Error("STRAVA_TOKEN_ENCRYPTION_KEY is not set");
    const keyBytes = base64ToBytes(raw.trim());
    if (keyBytes.length !== 32) {
      throw new Error("STRAVA_TOKEN_ENCRYPTION_KEY must decode to 32 bytes");
    }
    cachedKey = crypto.subtle.importKey(
      "raw",
      keyBytes,
      { name: "AES-GCM" },
      false,
      ["encrypt", "decrypt"],
    );
  }
  return cachedKey;
}

export async function encryptToken(plaintext: string): Promise<string> {
  const iv = crypto.getRandomValues(new Uint8Array(IV_BYTES));
  const ciphertext = new Uint8Array(
    await crypto.subtle.encrypt(
      { name: "AES-GCM", iv },
      await getKey(),
      new TextEncoder().encode(plaintext),
    ),
  );
  const out = new Uint8Array(iv.length + ciphertext.length);
  out.set(iv);
  out.set(ciphertext, iv.length);
  return PREFIX + bytesToBase64(out);
}

/** Decrypts a stored token. Values without the prefix are legacy plaintext and returned unchanged. */
export async function decryptToken(stored: string): Promise<string> {
  if (!stored.startsWith(PREFIX)) return stored;
  const bytes = base64ToBytes(stored.slice(PREFIX.length));
  const iv = bytes.slice(0, IV_BYTES);
  const ciphertext = bytes.slice(IV_BYTES);
  const plaintext = await crypto.subtle.decrypt(
    { name: "AES-GCM", iv },
    await getKey(),
    ciphertext,
  );
  return new TextDecoder().decode(plaintext);
}

export function isEncrypted(stored: string): boolean {
  return stored.startsWith(PREFIX);
}
