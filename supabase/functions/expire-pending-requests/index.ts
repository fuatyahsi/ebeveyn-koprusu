import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = serviceClient();
  const now = new Date().toISOString();

  const { error: invitationError } = await supabase
    .from("family_invitations")
    .update({ status: "expired" })
    .lt("expires_at", now)
    .eq("status", "pending");

  const { error: externalError } = await supabase
    .from("external_notifications")
    .update({ status: "expired" })
    .lt("expires_at", now)
    .eq("status", "sent");

  if (invitationError || externalError) {
    return jsonResponse({
      error: invitationError?.message ?? externalError?.message,
    }, 500);
  }

  return jsonResponse({ ok: true });
});
