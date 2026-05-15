import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

type ExternalDropboxLinkRequest = {
  family_id: string;
  child_id?: string;
  recipient_email?: string;
  recipient_phone?: string;
  subject?: string;
  body?: string;
  expires_in_hours?: number;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const payload = await readJson<ExternalDropboxLinkRequest>(request);
  const supabase = serviceClient();
  const authHeader = request.headers.get("Authorization") ?? "";
  const jwt = authHeader.replace("Bearer ", "");
  const { data: userResult, error: userError } = await supabase.auth.getUser(jwt);

  if (userError || !userResult.user) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  const { data: membership, error: membershipError } = await supabase
    .from("family_members")
    .select("id")
    .eq("family_id", payload.family_id)
    .eq("user_id", userResult.user.id)
    .eq("status", "active")
    .eq("access_level", "full")
    .limit(1)
    .maybeSingle();

  if (membershipError) {
    return jsonResponse({ error: membershipError.message }, 500);
  }

  if (!membership) {
    return jsonResponse({ error: "family_full_access_required" }, 403);
  }

  const expiresInHours = Math.min(
    Math.max(payload.expires_in_hours ?? 48, 1),
    168,
  );
  const token = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + expiresInHours * 60 * 60 * 1000)
    .toISOString();
  const channel = payload.recipient_phone ? "sms" : "email";

  const { data, error } = await supabase
    .from("external_notifications")
    .insert({
      family_id: payload.family_id,
      child_id: payload.child_id ?? null,
      created_by: userResult.user.id,
      channel,
      recipient_email: payload.recipient_email ?? null,
      recipient_phone: payload.recipient_phone ?? null,
      notification_type: "document_dropbox",
      related_entity_type: "document",
      subject: payload.subject ?? "Ebeveyn Köprüsü belge yükleme linki",
      body: payload.body ?? "Belgeyi güvenli bağlantı ile yükleyebilirsiniz.",
      token,
      expires_at: expiresAt,
    })
    .select("id,token,expires_at")
    .single();

  if (error) {
    return jsonResponse({ error: error.message }, 500);
  }

  const publicBaseUrl = Deno.env.get("PUBLIC_APP_URL") ?? "";
  return jsonResponse({
    ok: true,
    notification: data,
    upload_url: publicBaseUrl
      ? `${publicBaseUrl.replace(/\/$/, "")}/external/upload/${token}`
      : null,
  });
});
