import { createRemoteJWKSet, jwtVerify } from "https://esm.sh/jose@5";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!.trim();
console.log("🎯 ~ FIREBASE_PROJECT_ID:", FIREBASE_PROJECT_ID);
const JWKS = createRemoteJWKSet(
    new URL(
        "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
    ),
);

export class UnauthorizedError extends Error {}

/** Verifies a Firebase ID token and returns the UID (matches users.id). Throws UnauthorizedError on any failure. */
export async function requireUser(req: Request): Promise<string> {
    console.log("🎯 ~ requireUser ~ req:", req);
    const authHeader = req.headers.get("Authorization");
    console.log("🎯 ~ authHeader present:", !!authHeader);
    if (!authHeader?.startsWith("Bearer ")) {
        throw new UnauthorizedError("Missing bearer token");
    }

    try {
        const { payload } = await jwtVerify(
            authHeader.replace("Bearer ", ""),
            JWKS,
            {
                issuer: `https://securetoken.google.com/${FIREBASE_PROJECT_ID}`,
                audience: FIREBASE_PROJECT_ID,
            },
        );
        if (!payload.sub) throw new Error("Missing sub claim");
        console.log("🎯 ~ payload.sub:", payload.sub);
        return payload.sub;
    } catch (e) {
        console.log("🎯 ~ jwtVerify error:", e);
        throw new UnauthorizedError("Invalid or expired token");
    }
}
