import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(request.url);
  const token = url.searchParams.get("token");
  if (!token) {
    return jsonResponse({ valid: false, reason: "missing_token" }, 400);
  }

  const supabase = serviceClient();
  const { data, error } = await supabase
    .from("reports")
    .select("id,report_type,report_hash,generated_at")
    .eq("verification_token", token)
    .maybeSingle();

  if (error) {
    return jsonResponse({ valid: false, reason: error.message }, 500);
  }

  if (!data) {
    return jsonResponse({ valid: false, reason: "not_found" }, 404);
  }

  return jsonResponse({
    valid: true,
    report_type: data.report_type,
    report_hash: data.report_hash,
    generated_at: data.generated_at,
  });
});
