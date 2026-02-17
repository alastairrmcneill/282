import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js";

interface FollowerRecord {
  source_id: string;
  target_id: string;
}

interface Notification {
  id: string;
  target_id: string;
  source_id: string;
  post_id: string | null;
  type: string;
  detail: string | null;
  read: boolean;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: FollowerRecord;
  schema: "public";
}

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const follower = payload.record;
    const sourceId: string = follower.source_id;
    const targetId: string = follower.target_id;
    console.log("📱 ~ Inserted Follower:", follower);

    if (!sourceId || !targetId || sourceId === targetId) {
      console.warn("📱 ~ Invalid follow attempt:", { sourceId, targetId });
      return new Response("Invalid follow", { status: 400 });
    }

    const supabase: SupabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: notification, error } = await supabase
      .from("notifications")
      .insert({
        target_id: targetId,
        source_id: sourceId,
        post_id: null,
        type: "follow",
        detail: `followed you.`,
        read: false,
      })
      .select("id")
      .single<Notification>();

    if (error) {
      console.error("📱 ~ Failed to insert follow notification:", error);
      return new Response("Error", { status: 500 });
    }

    console.log("📱 ~ Notification created:", notification);
    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error("📱 ~ Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
