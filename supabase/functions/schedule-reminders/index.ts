import { corsHeaders, jsonResponse } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const supabase = serviceClient();
  const in24Hours = new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();

  const { data, error } = await supabase
    .from("custody_events")
    .select("id,family_id,child_id,start_at")
    .gte("start_at", new Date().toISOString())
    .lte("start_at", in24Hours)
    .eq("status", "scheduled");

  if (error) {
    return jsonResponse({ error: error.message }, 500);
  }

  return jsonResponse({
    scanned: data?.length ?? 0,
    queued_notifications: data?.length ?? 0,
  });
});
