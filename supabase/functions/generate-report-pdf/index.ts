import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";
import { serviceClient } from "../_shared/supabase.ts";

type ReportRequest = {
  family_id: string;
  child_id?: string;
  report_type: string;
  filters?: Record<string, unknown>;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<ReportRequest>(request);
  const verificationToken = crypto.randomUUID();
  const reportHash = await sha256(JSON.stringify(body));
  const storagePath = `families/${body.family_id}/reports/${verificationToken}.pdf`;

  const supabase = serviceClient();
  const { data, error } = await supabase
    .from("reports")
    .insert({
      family_id: body.family_id,
      child_id: body.child_id,
      report_type: body.report_type,
      filters: body.filters ?? {},
      storage_path: storagePath,
      report_hash: reportHash,
      verification_token: verificationToken,
    })
    .select()
    .single();

  if (error) {
    return jsonResponse({ error: error.message }, 500);
  }

  return jsonResponse({
    report: data,
    storage_path: storagePath,
    report_hash: reportHash,
    verification_token: verificationToken,
    pdf_generation_mode: "server-side placeholder",
  });
});

async function sha256(input: string): Promise<string> {
  const bytes = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
