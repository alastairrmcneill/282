import { createClient } from "npm:@supabase/supabase-js@2";

interface FeedbackRecord {
  id: string;
  user_id: string | null;
  date_time_provided: string;
  survey_number: number | null;
  answer_1: string | null;
  answer_2: string | null;
  app_version: string | null;
  platform: string | null;
}

interface WebhookPayload {
  type: "INSERT";
  table: string;
  record: FeedbackRecord;
  schema: "public";
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Fixed question text used by app_survey_dialog.dart regardless of survey_number.
const QUESTION_1 = "What do you like most about 282?";
const QUESTION_2 = "What would you like to see added to 282?";

Deno.serve(async (req: Request) => {
  try {
    const payload: WebhookPayload = await req.json();
    const feedback = payload.record;
    console.log("💬 ~ Inserted Feedback ID:", feedback.id);

    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const notificationEmail = Deno.env.get("NOTIFICATION_EMAIL");
    const fromEmail = Deno.env.get("FROM_EMAIL") ?? "onboarding@resend.dev";

    if (!resendApiKey || !notificationEmail) {
      throw new Error(
        "RESEND_API_KEY or NOTIFICATION_EMAIL secret is not set",
      );
    }

    let userName = "Anonymous";
    if (feedback.user_id) {
      const { data: user } = await supabase
        .from("users")
        .select("display_name")
        .eq("id", feedback.user_id)
        .single();
      userName = user?.display_name ?? "Unknown user";
    }

    const html = buildEmailHtml(feedback, userName);

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: `282 Feedback <${fromEmail}>`,
        to: [notificationEmail],
        subject: `New app feedback from ${userName}`,
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
    console.error("💬 ~ Unexpected error:", err);
    return new Response(
      JSON.stringify({ error: err instanceof Error ? err.message : "Unknown error" }),
      { status: 500, headers: { "Content-Type": "application/json" } },
    );
  }
});

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");
}

function buildEmailHtml(feedback: FeedbackRecord, userName: string): string {
  return `
<!DOCTYPE html>
<html>
<head><meta charset="utf-8"></head>
<body style="font-family: -apple-system, sans-serif; max-width: 560px; margin: 0 auto; padding: 32px 16px; color: #1a1a1a;">
  <p style="font-size: 12px; text-transform: uppercase; letter-spacing: 0.2em; color: #666; margin-bottom: 8px;">282</p>
  <h1 style="font-size: 24px; margin: 0 0 24px;">New app feedback</h1>

  <table style="width: 100%; border-collapse: collapse; font-size: 15px;">
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666; width: 140px;">From</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; font-weight: bold;">${escapeHtml(userName)}</td>
    </tr>
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666;">App version</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${escapeHtml(feedback.app_version ?? "unknown")} (${escapeHtml(feedback.platform ?? "unknown")})</td>
    </tr>
    <tr>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd; color: #666;">Submitted</td>
      <td style="padding: 10px 0; border-bottom: 1px solid #ddd;">${escapeHtml(feedback.date_time_provided)}</td>
    </tr>
  </table>

  <p style="margin: 24px 0 8px; color: #666; font-size: 13px;">${escapeHtml(QUESTION_1)}</p>
  <p style="margin: 0 0 24px; line-height: 1.6; font-size: 15px;">${escapeHtml(feedback.answer_1 ?? "(no answer)")}</p>

  <p style="margin: 0 0 8px; color: #666; font-size: 13px;">${escapeHtml(QUESTION_2)}</p>
  <p style="margin: 0; line-height: 1.6; font-size: 15px;">${escapeHtml(feedback.answer_2 ?? "(no answer)")}</p>
</body>
</html>`;
}
