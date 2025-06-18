import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js";

interface LikeRecord {
  id: string;
  post_id: string;
  user_id: string;
}

interface Post {
  id: string;
  author_id: string;
}

interface Notification {
  id: string;
  target_id: string;
  source_id: string;
  post_id: string;
  type: string;
  read: boolean;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: LikeRecord;
  schema: "public";
}

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const like: LikeRecord = payload.record;
    console.log("📱 ~ Inserted Like ID:", like.id);

    const supabase: SupabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: post, error: postError } = await supabase
      .from("posts")
      .select("id,author_id")
      .eq("id", like.post_id)
      .single<Post>();

    if (postError) {
      console.error(
        "📱 ~ Error fetching post:",
        postError,
        "Post ID:",
        like.post_id,
      );
      return new Response("Post not found", { status: 404 });
    }
    if (!post) {
      console.error("📱 ~ Post not found:", like.post_id);
      return new Response("Post not found", { status: 404 });
    }
    console.log("📱 ~ Associated Post:", post);

    const { data: notification, error: notificationError } = await supabase
      .from("notifications")
      .insert({
        target_id: post.author_id,
        source_id: like.user_id,
        post_id: like.post_id,
        type: "like",
        read: false,
      })
      .select("id, target_id, source_id, post_id, type, read")
      .single<Notification>();

    if (notificationError) {
      console.error("📱 ~ Failed to insert notification:", notificationError);
      return new Response("Error", { status: 500 });
    }

    console.log("📱 ~ Created Notification:", notification);
    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error("📱 ~ Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
