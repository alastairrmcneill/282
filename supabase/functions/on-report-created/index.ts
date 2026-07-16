import { createClient } from "npm:@supabase/supabase-js@2";

interface ReportRecord {
  id: string;
  reporter_id: string;
  type: string | null;
  content_id: string | null;
  comment: string | null;
  completed: boolean | null;
  date_time_created: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: ReportRecord;
  schema: "public";
}

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;

const supabase = createClient(
  supabaseUrl,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// SUPABASE_URL is https://<project-ref>.supabase.co — reuse the ref so the
// dashboard link is correct in whichever project (dev/prod) this deploys to.
const projectRef = new URL(supabaseUrl).hostname.split(".")[0];
const DASHBOARD_URL = `https://supabase.com/dashboard/project/${projectRef}/editor`;

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const report = payload.record;
    console.log("🚩 ~ Inserted Report ID:", report.id);

    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const notificationEmail = Deno.env.get("NOTIFICATION_EMAIL");
    const fromEmail = Deno.env.get("FROM_EMAIL") ?? "onboarding@resend.dev";

    if (!resendApiKey || !notificationEmail) {
      throw new Error(
        "RESEND_API_KEY or NOTIFICATION_EMAIL secret is not set",
      );
    }

    const { data: reporter } = await supabase
      .from("users")
      .select("display_name")
      .eq("id", report.reporter_id)
      .single();

    const contentPreview = await getContentPreview(report);

    const html = buildEmailHtml(report, reporter?.display_name ?? null, contentPreview);

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: `282 Reports <${fromEmail}>`,
        to: [notificationEmail],
        subject: `New report: ${report.type ?? "unknown type"}`,
        html,
      }),
    });

    if (!res.ok) {
      const body = await res.text();
      throw new Error(`Resend API error ${res.status}: ${body}`);
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { "Content-Type": "application/json" },
    });
  } catch (err) {
    console.error("🚩 ~ Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Unknown error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});

interface ContentPreview {
  label: string;
  lines: string[];
}

async function getContentPreview(report: ReportRecord): Promise<ContentPreview> {
  const contentId = report.content_id;
  if (!contentId) {
    return { label: "Content", lines: ["No content reference provided."] };
  }

  try {
    switch (report.type) {
      case "post": {
        const { data } = await supabase
          .from("posts")
          .select("title, description, users(display_name)")
          .eq("id", contentId)
          .single();
        if (!data) return notFound("Post");
        const author = (data.users as unknown as { display_name: string } | null)
          ?.display_name;
        return {
          label: "Post",
          lines: [
            `Author: ${author ?? "Unknown"}`,
            `Title: ${data.title ?? "(no title)"}`,
            `Description: ${data.description ?? "(none)"}`,
          ],
        };
      }
      case "comment": {
        const commentId = contentId.split("/")[1];
        if (!commentId) return notFound("Comment");
        const { data } = await supabase
          .from("comments")
          .select("text, users(display_name)")
          .eq("id", commentId)
          .single();
        if (!data) return notFound("Comment");
        const author = (data.users as unknown as { display_name: string } | null)
          ?.display_name;
        return {
          label: "Comment",
          lines: [
            `Author: ${author ?? "Unknown"}`,
            `Text: ${data.text ?? "(none)"}`,
          ],
        };
      }
      case "review": {
        const { data } = await supabase
          .from("reviews")
          .select("rating, text, users(display_name), munros(name)")
          .eq("id", contentId)
          .single();
        if (!data) return notFound("Review");
        const author = (data.users as unknown as { display_name: string } | null)
          ?.display_name;
        const munro = (data.munros as unknown as { name: string } | null)?.name;
        return {
          label: "Review",
          lines: [
            `Author: ${author ?? "Unknown"}`,
            `Munro: ${munro ?? "Unknown"}`,
            `Rating: ${data.rating ?? "(none)"}`,
            `Text: ${data.text ?? "(none)"}`,
          ],
        };
      }
      case "user": {
        const { data } = await supabase
          .from("users")
          .select("display_name")
          .eq("id", contentId)
          .single();
        if (!data) return notFound("User");
        return {
          label: "Reported user",
          lines: [`Name: ${data.display_name ?? "Unknown"}`],
        };
      }
      default:
        return { label: "Content", lines: [`Unknown report type: ${report.type}`] };
    }
  } catch (err) {
    console.error("🚩 ~ Error fetching content preview:", err);
    return { label: "Content", lines: ["Could not load content (it may have been deleted)."] };
  }
}

function notFound(kind: string): ContentPreview {
  return { label: kind, lines: [`${kind} no longer exists (may have been deleted).`] };
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function buildEmailHtml(
  report: ReportRecord,
  reporterName: string | null,
  preview: ContentPreview,
): string {
  const previewHtml = preview.lines
    .map((line) => `<p style="margin: 4px 0; line-height: 1.5;">${escapeHtml(line)}</p>`)
    .join("");

  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family: -apple-system, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 16px; color: #1a1a1a;">
  <p style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.2em; color: #666; margin-bottom: 8px;">282</p>
  <h1 style="font-size: 24px; margin: 0 0 24px;">New content report</h1>

  <table style="width: 100%; border-collapse: collapse; font-size: 15px;">
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666; width: 140px;">Type</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; font-weight: bold;">${escapeHtml(report.type ?? "unknown")}</td>
    </tr>
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666;">Reported by</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${escapeHtml(reporterName ?? report.reporter_id)}</td>
    </tr>
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666;">Submitted</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${escapeHtml(report.date_time_created)}</td>
    </tr>
  </table>

  <p style="margin: 24px 0 8px; color: #666; font-size: 13px;">Reporter's comment</p>
  <p style="margin: 0 0 24px; line-height: 1.6; font-size: 15px;">${escapeHtml(report.comment ?? "(none)")}</p>

  <p style="margin: 24px 0 8px; color: #666; font-size: 13px;">${escapeHtml(preview.label)}</p>
  ${previewHtml}

  <div style="margin-top: 32px;">
    <a href="${DASHBOARD_URL}" style="display: inline-block; background: #1a1a1a; color: #fff; padding: 12px 24px; border-radius: 999px; text-decoration: none; font-size: 14px;">Review in Supabase →</a>
  </div>
</body>
</html>`;
}
