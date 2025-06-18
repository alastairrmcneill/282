import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";

interface CommentRecord {
  id: string;
  post_id: string;
  author_id: string;
}

interface Post {
  id: string;
  author_id: string;
}

interface Notification {
  target_id: string;
  source_id: string;
  post_id: string;
  type: string;
  read: boolean;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: CommentRecord;
  schema: "public";
}

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const comment = payload.record;
    console.log("📱 ~ Inserted Comment ID:", comment.id);
    const postId = comment.post_id;
    const sourceId = comment.author_id;

    const supabase: SupabaseClient = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    // Get the post to ensure it exists
    const { data: post, error: postError } = await supabase
      .from("posts")
      .select("id,author_id")
      .eq("id", postId)
      .single<Post>();

    if (postError) {
      console.error("📱 ~ Error fetching post:", postError, "Post ID:", postId);
      return new Response("Post not found", { status: 404 });
    }
    if (!post) {
      console.error("📱 ~ Post not found:", postId);
      return new Response("Post not found", { status: 404 });
    }
    console.log("📱 ~ Associated Post:", post);

    // Step 1: Get all distinct author_ids who commented on the same post
    const { data: comments, error: commentsError } = await supabase
      .from("comments")
      .select("author_id")
      .eq("post_id", postId);

    if (commentsError) {
      console.error("📱 ~ Failed to fetch comments:", commentsError);
    }

    // Step 2: Get unique target IDs excluding the commenter
    const targetIds = Array.from(
      new Set(
        (comments ?? []).map((c: { author_id: string }) => c.author_id).filter((
          id,
        ) => id !== sourceId),
      ),
    );

    // Add the post author to the target IDs if they are not already included
    if (post.author_id !== sourceId && !targetIds.includes(post.author_id)) {
      targetIds.push(post.author_id);
    }

    if (targetIds.length === 0) {
      console.log("📱 ~ No notifications to send for comment:", comment.id);
      return new Response("No notifications to send", { status: 200 });
    }

    // Step 3: Insert notifications
    const notifications: Notification[] = targetIds.map((targetId) => {
      console.log("📱 ~ Creating notification for targetId:", targetId);
      return {
        target_id: targetId,
        source_id: sourceId,
        post_id: postId,
        type: "comment",
        read: false,
      };
    });

    const { data: notificationIds, error: insertError } = await supabase
      .from("notifications")
      .insert(notifications)
      .select("id");

    if (insertError) {
      console.error("📱 ~ Failed to insert notifications:", insertError);
      return new Response("Failed to create notifications", { status: 500 });
    }

    (notificationIds ?? []).forEach((notif) => {
      console.log("📱 ~ Created Notification ID:", notif.id);
    });

    return new Response("OK", { status: 200 });
  } catch (err) {
    console.error("📱 ~ Unexpected error:", err);
    return new Response("Internal Server Error", { status: 500 });
  }
});
