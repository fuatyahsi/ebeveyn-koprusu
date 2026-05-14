import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type AuditHashRequest = {
  previous_hash?: string;
  action: string;
  entity_type: string;
  entity_id: string;
  payload?: Record<string, unknown>;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<AuditHashRequest>(request);
  const canonical = JSON.stringify({
    previous_hash: body.previous_hash ?? "",
    action: body.action,
    entity_type: body.entity_type,
    entity_id: body.entity_id,
    payload: body.payload ?? {},
  });

  return jsonResponse({ current_hash: await sha256(canonical) });
});

async function sha256(input: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(input),
  );
  return Array.from(new Uint8Array(digest))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}
