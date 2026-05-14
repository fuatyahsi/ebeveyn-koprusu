import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type NotificationPayload = {
  family_id?: string;
  user_ids?: string[];
  type: string;
  title?: string;
  body?: string;
  data?: Record<string, unknown>;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const payload = await readJson<NotificationPayload>(request);
  const safeBody = sanitizeNotificationBody(payload.body ?? "");

  return jsonResponse({
    queued: true,
    provider: "fcm",
    type: payload.type,
    title: payload.title ?? "Ebeveyn Köprüsü",
    body: safeBody,
    recipients: payload.user_ids?.length ?? 0,
  });
});

function sanitizeNotificationBody(body: string): string {
  const blocked = ["rapor", "alerji", "psikolog", "tutar", "mahkeme"];
  const lower = body.toLocaleLowerCase("tr");
  if (blocked.some((word) => lower.includes(word))) {
    return "Yeni bir kayıt güncellendi.";
  }
  return body || "Yeni bir bildirim var.";
}
