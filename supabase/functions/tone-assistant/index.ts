import { corsHeaders, jsonResponse, readJson } from "../_shared/http.ts";

type ToneRequest = {
  text: string;
  locale?: string;
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const body = await readJson<ToneRequest>(request);
  const lower = body.text.toLocaleLowerCase(body.locale ?? "tr");
  const riskyWords = ["yine", "hiçbir", "asla", "sorumsuz", "suç"];
  const hits = riskyWords.filter((word) => lower.includes(word));

  return jsonResponse({
    provider: Deno.env.get("TONE_ASSISTANT_PROVIDER") ?? "mock",
    risk_score: Math.min(95, hits.length * 22),
    categories: hits.length ? ["suçlayıcı dil", "genelleme"] : ["nötr"],
    suggestion:
      "Bugünkü konu hakkında kısa bir not paylaşmak istiyorum. Çocuğun düzeni için belirlenen saat ve bilgilere birlikte uymamızı rica ederim.",
  });
});
