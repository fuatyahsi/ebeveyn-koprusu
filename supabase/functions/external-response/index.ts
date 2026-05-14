import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

type ExternalResponseRequest = {
  token: string;
  response: "accepted" | "rejected" | "counter_proposed" | "more_info" | "read";
  note?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<ExternalResponseRequest>(request);
  const supabase = serviceClient();
  const { data: notification, error: findError } = await supabase
    .from("external_notifications")
    .select("id,expires_at,status")
    .eq("token", body.token)
    .maybeSingle();

  if (findError) {
    return jsonResponse({ error: findError.message }, 500);
  }

  if (!notification) {
    return jsonResponse({ error: "not_found" }, 404);
  }

  if (new Date(notification.expires_at).getTime() < Date.now()) {
    return jsonResponse({ error: "expired" }, 410);
  }

  const { error: updateError } = await supabase
    .from("external_notifications")
    .update({
      status: "responded",
      responded_at: new Date().toISOString(),
      response_payload: {
        response: body.response,
        note: body.note,
      },
      ip_address: request.headers.get("x-forwarded-for"),
      user_agent: request.headers.get("user-agent"),
    })
    .eq("token", body.token);

  if (updateError) {
    return jsonResponse({ error: updateError.message }, 500);
  }

  return jsonResponse({ ok: true, response: body.response });
});
