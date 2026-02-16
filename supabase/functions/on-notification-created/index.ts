import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

interface Notification {
  id: string;
  target_id: string;
  source_id: string;
  post_id: string | null;
  type: "like" | "comment" | "follow";
  read: boolean | null;
  detail: string | null;
  date_time_created: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: Notification;
  schema: "public";
}

interface UserFcmToken {
  id: string;
  user_id: string;
  token: string;
  device_id: string;
  platform: string;
  is_active: boolean;
  push_enabled: boolean;
  created_at: string;
  updated_at: string;
}

interface FcmSendResult {
  tokenId: string;
  token: string;
  success: boolean;
  error?: string;
  errorCode?: string;
}

// FCM error codes that indicate the token should be deleted
const INVALID_TOKEN_ERROR_CODES = [
  "UNREGISTERED",
  "NOT_FOUND",
  "INVALID_ARGUMENT",
];

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    const notification = payload.record;
    console.log("📱 ~ Inserted Notification ID:", notification.id);

    // Get all active FCM tokens for the target user
    const { data: fcmTokens, error: tokensError } = await supabase
      .from("user_fcm_tokens")
      .select("*")
      .eq("user_id", notification.target_id)
      .eq("is_active", true)
      .eq("push_enabled", true);

    console.log(
      "📱 ~ Found FCM tokens for user:",
      notification.target_id,
      "count:",
      fcmTokens?.length ?? 0,
    );

    if (tokensError) {
      console.error("Error fetching FCM tokens:", tokensError);
      return new Response("Error fetching FCM tokens", { status: 500 });
    }

    if (!fcmTokens || fcmTokens.length === 0) {
      console.log(
        "📱 ~ No active FCM tokens for target:",
        notification.target_id,
      );
      return new Response("No FCM tokens", { status: 200 });
    }

    // Get source user's display name
    const { data: sourceUser, error: sourceError } = await supabase
      .from("users")
      .select("*")
      .eq("id", notification.source_id)
      .single();

    console.log("📱 ~ sourceUser:", sourceUser);

    if (sourceError) {
      console.error("Error fetching source user:", sourceError);
      return new Response("Source user not found", { status: 404 });
    }

    const title = getNotificationTitle(
      sourceUser.display_name,
      notification.detail,
    );

    const serviceAccount = JSON.parse(
      atob(Deno.env.get("FIREBASE_SERVICE_ACCOUNT_BASE64")!),
    );

    const accessToken = await getAccessToken(serviceAccount);

    // Send notifications to all tokens in parallel
    const sendPromises = fcmTokens.map((tokenRecord: UserFcmToken) =>
      sendFcmNotification(
        tokenRecord,
        title,
        notification,
        serviceAccount.project_id,
        accessToken,
      )
    );

    const results = await Promise.all(sendPromises);

    // Process results and clean up invalid tokens
    const invalidTokenIds = results
      .filter(
        (r: FcmSendResult) =>
          !r.success && r.errorCode &&
          INVALID_TOKEN_ERROR_CODES.includes(r.errorCode),
      )
      .map((r: FcmSendResult) => r.tokenId);

    if (invalidTokenIds.length > 0) {
      console.log("📱 ~ Deleting invalid tokens:", invalidTokenIds);
      const { error: deleteError } = await supabase
        .from("user_fcm_tokens")
        .delete()
        .in("id", invalidTokenIds);

      if (deleteError) {
        console.error("Error deleting invalid tokens:", deleteError);
      } else {
        console.log(
          "📱 ~ Successfully deleted",
          invalidTokenIds.length,
          "invalid tokens",
        );
      }
    }

    const successCount = results.filter((r: FcmSendResult) => r.success).length;
    const failCount = results.filter((r: FcmSendResult) => !r.success).length;

    console.log(
      "📱 ~ Notification",
      notification.id,
      "sent to",
      successCount,
      "devices,",
      failCount,
      "failed",
    );

    return new Response(
      JSON.stringify({
        notificationId: notification.id,
        totalTokens: fcmTokens.length,
        successCount,
        failCount,
        invalidTokensRemoved: invalidTokenIds.length,
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response("Internal server error", { status: 500 });
  }
});

async function sendFcmNotification(
  tokenRecord: UserFcmToken,
  title: string,
  notification: Notification,
  projectId: string,
  accessToken: string,
): Promise<FcmSendResult> {
  try {
    console.log(
      "📱 ~ Sending to device:",
      tokenRecord.device_id,
      "platform:",
      tokenRecord.platform,
    );

    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: tokenRecord.token,
            notification: {
              title,
            },
            data: {
              type: notification.type,
              postId: notification.post_id ?? "",
              detail: notification.detail ?? "",
            },
          },
        }),
      },
    );

    const responseBody = await res.json();

    if (!res.ok) {
      // Extract error code from FCM response
      const errorCode = responseBody?.error?.details?.[0]?.errorCode ||
        responseBody?.error?.status ||
        "UNKNOWN";

      console.error(
        "📱 ~ FCM error for token",
        tokenRecord.id,
        ":",
        errorCode,
        responseBody,
      );

      return {
        tokenId: tokenRecord.id,
        token: tokenRecord.token,
        success: false,
        error: JSON.stringify(responseBody),
        errorCode,
      };
    }

    console.log("📱 ~ Successfully sent to device:", tokenRecord.device_id);
    return {
      tokenId: tokenRecord.id,
      token: tokenRecord.token,
      success: true,
    };
  } catch (err) {
    console.error(
      "📱 ~ Exception sending to token",
      tokenRecord.id,
      ":",
      err,
    );
    return {
      tokenId: tokenRecord.id,
      token: tokenRecord.token,
      success: false,
      error: String(err),
    };
  }
}

function getNotificationTitle(name: string, detail: string | null): string {
  if (detail) {
    return `${name} ${detail}`;
  }
  return `You have a new notification.`;
}

async function getAccessToken(serviceAccount: {
  client_email: string;
  private_key: string;
}): Promise<string> {
  const jwtClient = new JWT({
    email: serviceAccount.client_email,
    key: serviceAccount.private_key,
    scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
  });

  const tokens = await jwtClient.authorize();
  if (!tokens?.access_token) throw new Error("No access token");
  return tokens.access_token;
}
