import { createRemoteJWKSet, jwtVerify } from "https://esm.sh/jose@5";

const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!.trim();
const JWKS = createRemoteJWKSet(
    new URL(
        "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com",
    ),
);

export class UnauthorizedError extends Error {}

/** Verifies a Firebase ID token and returns the UID (matches users.id). Throws UnauthorizedError on any failure. */
export async function requireUser(req: Request): Promise<string> {
    const authHeader = req.headers.get("Authorization");
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
        return payload.sub;
    } catch (_) {
        throw new UnauthorizedError("Invalid or expired token");
    }
}
