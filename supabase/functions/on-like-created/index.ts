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
  detail: string;
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

    // Get munro_completions from the post_id
    const { data: munroCompletions, error: munroCompletionsError } =
      await supabase
        .from("munro_completions")
        .select("munro_id, munros(name)")
        .eq("post_id", like.post_id);

    let detail: string;

    if (
      !munroCompletionsError &&
      munroCompletions &&
      munroCompletions.length > 0
    ) {
      console.log(
        "📱 ~ Found munro completions for post_id:",
        like.post_id,
        "Munro Completions:",
        munroCompletions,
      );
      const munro = munroCompletions[0].munros as unknown as
        | { name: string }
        | null;
      detail = munro ? `liked your ${munro.name} post.` : "liked your post.";
    } else {
      console.log(
        "📱 ~ No munro completions found for post_id:",
        like.post_id,
        "Error:",
        munroCompletionsError,
      );
      detail = "liked your post.";
    }

    const { data: notification, error: notificationError } = await supabase
      .from("notifications")
      .insert({
        target_id: post.author_id,
        source_id: like.user_id,
        post_id: like.post_id,
        type: "like",
        read: false,
        detail: detail,
      })
      .select("id, target_id, source_id, post_id, type, read, detail")
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
