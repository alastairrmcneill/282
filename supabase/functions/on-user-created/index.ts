import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js";

interface UserRecord {
  id: string;
}

interface Follower {
  id: string;
  source_id: string;
  target_id: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: UserRecord;
  schema: "public";
}

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const newUser = payload.record;
    const newUserId: string = newUser.id;
    const SYSTEM_USER_ID: string | undefined = Deno.env.get("SYSTEM_USER_ID");
    console.log("📱 ~ Inserted User Id:", newUserId);
    console.log("📱 ~ SYSTEM_USER_ID:", SYSTEM_USER_ID);

    if (!newUserId || !SYSTEM_USER_ID) {
      console.error("📱 ~ Missing newUserId or SYSTEM_USER_ID.");
      return new Response("Missing user IDs", { status: 400 });
    }

    const supabase: SupabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Create "new user follows system user"
    const { data: follower1, error: error1 } = await supabase
      .from("followers")
      .insert({
        source_id: newUserId,
        target_id: SYSTEM_USER_ID,
      })
      .select()
      .single<Follower>();

    if (error1) {
      console.error("📱 ~ Failed to insert new follower", error1);
      return new Response("Error", { status: 500 });
    }
    console.log("📱 ~ New follower created:", follower1);

    // Create "system user follows new user"
    const { data: follower2, error: error2 } = await supabase
      .from("followers")
      .insert({
        source_id: SYSTEM_USER_ID,
        target_id: newUserId,
      });

    if (error2) {
      console.error("📱 ~ Failed to insert new follower", error2);
      return new Response("Error", { status: 500 });
    }
    console.log("📱 ~ New follower created:", follower2);

    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error("📱 ~ Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
