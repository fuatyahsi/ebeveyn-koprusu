import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

type InviteRequest = {
  family_id: string;
  invited_email?: string;
  invited_phone?: string;
  invited_role: string;
  created_by: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<InviteRequest>(request);
  const code = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
  const supabase = serviceClient();

  const { data, error } = await supabase
    .from("family_invitations")
    .insert({
      family_id: body.family_id,
      invited_email: body.invited_email,
      invited_phone: body.invited_phone,
      invited_role: body.invited_role,
      invitation_code: code,
      expires_at: expiresAt,
      created_by: body.created_by,
    })
    .select()
    .single();

  if (error) {
    return jsonResponse({ error: error.message }, 500);
  }

  return jsonResponse({
    invitation: data,
    deep_link: `ebeveynkoprusu://invite/${code}`,
  });
});
