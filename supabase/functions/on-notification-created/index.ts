import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

interface Notification {
  id: string;
  target_id: string;
  source_id: string;
  post_id: string | null;
  type: "like" | "comment" | "follow";
  read: boolean | null;
  date_time_created: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: Notification;
  schema: "public";
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    const notification = payload.record;
    console.log("📱 ~ Inserted Notification ID:", notification.id);

    // Get target user’s FCM token
    const { data: targetUser, error: targetError } = await supabase
      .from("users")
      .select("*")
      .eq("id", notification.target_id)
      .single();

    console.log("📱 ~ targetUser:", targetUser);

    if (targetError) {
      console.error("Error fetching target user:", targetError);
      return new Response("Target user not found", { status: 404 });
    }

    if (!targetUser?.fcm_token) {
      console.error("No FCM token for target:", notification.target_id);
      return new Response("No FCM token", { status: 200 });
    }

    // Get source user’s display name
    const { data: sourceUser, error: sourceError } = await supabase
      .from("users")
      .select("*")
      .eq("id", notification.source_id)
      .single();

    console.log("📱 ~ sourceUser:", sourceUser);

    if (sourceError) {
      console.error("Error fetching source user:", sourceError);
      return new Response("Target user not found", { status: 404 });
    }

    const title = getNotificationTitle(
      notification.type,
      sourceUser.display_name,
    );

    const serviceAccount = JSON.parse(
      atob(Deno.env.get("FIREBASE_SERVICE_ACCOUNT_BASE64")!),
    );

    const accessToken = await getAccessToken(serviceAccount);

    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: targetUser.fcm_token,
            notification: {
              title,
            },
            data: {
              type: notification.type,
              postId: notification.post_id ?? "",
            },
          },
        }),
      },
    );

    const responseBody = await res.json();
    if (!res.ok) {
      console.error("FCM error:", responseBody);
      return new Response("Failed to send FCM", { status: 500 });
    }

    console.log("📱 ~ Notification sent successfully:", notification.id);
    return new Response(JSON.stringify(responseBody), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("Unexpected error:", err);
    return new Response("Internal server error", { status: 500 });
  }
});

function getNotificationTitle(type: string, name: string): string {
  switch (type) {
    case "like":
      return `${name} liked your post.`;
    case "comment":
      return `${name} commented on a post you follow.`;
    case "follow":
      return `${name} followed you.`;
    default:
      return `You have a new notification.`;
  }
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
