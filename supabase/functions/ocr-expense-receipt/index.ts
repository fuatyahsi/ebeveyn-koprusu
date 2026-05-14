import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type OcrRequest = {
  document_id: string;
  storage_path: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<OcrRequest>(request);
  return jsonResponse({
    document_id: body.document_id,
    storage_path: body.storage_path,
    extraction_mode: "mock",
    fields: {
      merchant: null,
      amount: null,
      date: null,
    },
  });
});
